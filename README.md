# cmp-mini-snippets

[mini.snippets](https://github.com/echasnovski/mini.snippets) completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

Installation, using lazy.nvim
```lua
{
    "hrsh7th/nvim-cmp",
    lazy = false,
    dependencies = {
        {
            "echasnovski/mini.snippets",
            version = false,
            config = function()
                local gen_loader = require("mini.snippets").gen_loader
                require("mini.snippets").setup({
                    snippets = {
                        gen_loader.from_lang(), -- This includes those defined by friendly-snippets.
                    },
                })
            end,
        },
        "xzbdmw/cmp-mini-snippets",
    },
    config = function(_, opts)
        require("cmp").setup({
            snippet = {
                -- Snippets from lsp, you should set this even you don't use this plugin.
                expand = function(args)
                    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
                    insert({ body = args.body })
                end,
            },
            sources = require("cmp").config.sources({
                -- Snippets from mini.snippets, to make them appear at completion list.
                { name = "mini.snippets" },
            }, {}),
        })
    end,
},
```

# Option

```lua
sources = {
    { name = 'mini.snippets', option = { use_minisnippets_match_rule = false } },
},
```

By default, the option is false, which means it will feed nvim-cmp all the
avalible snippets and let cmp do the fuzzy match job.
However, mini.snippets has its own matching rule,
set to true to use mini.snippets rule in every keystroke.
For example:

```lua
local my_m = function(snippet, pos)
    -- With this match rule and `use_minisnippets_match_rule=true`,
    -- this plugin won't feed cmp items unless the match is exact.
    return MiniSnippets.default_match(snippet, { pattern_fuzzy = "" })
end
require("mini.snippets").setup({
    -- Note that even if you don’t have any custom match rules set up,
    -- it’s not guaranteed that mini.snippets will respond whenever
    -- cmp requests new snippets, as it may not always consider it the right time,
    -- in the case of `use_minisnippets_match_rule=true`.
    expand = {
        match = my_m,
    }
})
```
