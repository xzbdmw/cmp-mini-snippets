local cmp = require("cmp")

local source = {}

local defaults = {
    -- what should be the option?
}

local function init_options(params)
    -- Merge user’s cmp source opts with our defaults, currently none.
    params.option = vim.tbl_deep_extend("force", defaults, params.option or {})
    -- vim.validate({
    -- 	ignore_empty_prefix = { params.option.ignore_empty_prefix, "boolean" },
    -- })
end

function source.new()
    return setmetatable({}, { __index = source })
end

function source.get_debug_name(self)
    return "mini.snippets"
end

function source.is_available(self)
    -- Only enable this source if mini.snippets is loaded and user has called
    -- require('mini.snippets').setup() at some point.
    return _G.MiniSnippets ~= nil
end

function source.complete(self, params, callback)
    init_options(params)

    -- Retrieve all snippets for the current buffer context from mini.snippets
    -- Use `match = false` so we get *all* snippets, because cmp will not request
    -- completion at every keystrok, so let cmp do the fuzzy match job.
    -- and `insert = false` so we don’t actually insert anything.
    local all_snippets = MiniSnippets.expand({ match = false, insert = false })
    local items = {}
    for _, snip in ipairs(all_snippets or {}) do
        if snip.prefix ~= nil then
            if snip.prefix ~= "" then
                table.insert(items, {
                    label = snip.prefix,
                    insertTextFormat = 2,
                    word = snip.prefix,
                    kind = cmp.lsp.CompletionItemKind.Snippet,
                    data = {
                        snippet = snip,
                    },
                    documentation = {
                        kind = cmp.lsp.MarkupKind.Markdown,
                        value = snip.desc .. "\n" .. "```" .. vim.bo.filetype .. "\n" .. snip.body .. "\n" .. "```",
                    },
                })
            end
        end
    end

    callback(items)
end

-- When to call this?
function source.reload()
    _G.MiniSnippets.setup(_G.MiniSnippets.config)
end

function source.execute(self, completion_item, callback)
    local snip = completion_item.data.snippet
    if not snip then
        return callback(completion_item)
    end

    local match = MiniSnippets.config.expand.match or MiniSnippets.default_match
    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert

    -- Insert the snippet at the cursor. Because ‘nvim-cmp’ already typed the
    -- snippet’s prefix, we might want to remove it first. However, mini.snippets
    -- “insert” logic can handle that if we set region, so we first try remove it
    -- using default_match's region, and fallback to use cmp's information.
    local m = match({ snip })
    if m ~= nil and #m > 0 then
        insert(m[1])
    else
        -- Handle the case when match does not return anything, when will this happen?
        -- Anyway, be defensive.
        local cursor = vim.api.nvim_win_get_cursor(0)
        local clear_region = {
            from = {
                line = cursor[1],
                col = cursor[2] - #completion_item.word,
            },
            to = {
                line = cursor[1],
                to = cursor[2],
            },
        }
        insert(snip)
    end

    callback(completion_item)
end

return source
