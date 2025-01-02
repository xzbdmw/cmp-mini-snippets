local cmp = require("cmp")

local source = {}

local defaults = {
    -- By default, the option is false, which means it will feed nvim-cmp all the
    -- matches and let cmp do the fuzzy match job.
    -- However, mini.snippets has its own matching rule,
    -- set to true to use mini.snippets rule in every keystroke.
    use_minisnippets_match_rule = false,
}

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
    params.option = vim.tbl_deep_extend("force", defaults, params.option or {})
    local opts = params.option

    -- Retrieve all snippets for the current buffer context from mini.snippets
    -- Use `match = false` so we get *all* snippets, because cmp will not request
    -- completion at every keystroke, so let cmp do the fuzzy match job.
    -- Use `insert = false` so we don’t actually insert anything.
    local all_snippets
    if opts.use_minisnippets_match_rule then
        all_snippets = MiniSnippets.expand({ insert = false })
    else
        all_snippets = MiniSnippets.expand({ match = false, insert = false })
    end
    local items = {}
    for _, snip in ipairs(all_snippets or {}) do
        if snip.prefix ~= nil and snip.prefix ~= "" then
            local desc = snip.desc or snip.description or snip.prefix
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
                    value = desc .. "\n" .. "```" .. vim.bo.filetype .. "\n" .. snip.body .. "\n" .. "```",
                },
            })
        end
    end

    if opts.use_minisnippets_match_rule then
        callback({
            items = items,
            isIncomplete = true,
        })
    else
        callback({
            items = items,
        })
    end
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

    -- Insert the snippet at the cursor. Because cmp already typed the
    -- snippet’s prefix, we might want to remove it first. However, mini.snippets'
    -- `insert` logic can handle that if we set `region`, so first try to remove it
    -- using default_match's returned `region`, then fallback to use cmp's information.
    local m = match({ snip })
    if m ~= nil and #m > 0 then
        insert(m[1])
    else
        -- Handle the case when match does not return anything, when will this happen?
        -- Anyway, be defensive.
        local cursor = vim.api.nvim_win_get_cursor(0)
        snip.region = {
            from = {
                line = cursor[1],
                col = cursor[2] - #completion_item.word + 1,
            },
            to = {
                line = cursor[1],
                col = cursor[2],
            },
        }
        insert(snip)
    end

    callback(completion_item)
end

return source
