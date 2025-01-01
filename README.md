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
