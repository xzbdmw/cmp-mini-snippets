# cmp_mini_snippets

[mini-snippets](https://github.com/echasnovski/mini.snippets) completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

Installation
```lua
    {
        "echasnovski/mini.snippets",
        version = false,
        config = function()
            local gen_loader = require("mini.snippets").gen_loader
            require("mini.snippets").setup({
                snippets = {
                    -- Load custom file with global snippets first (adjust for Windows)
                    gen_loader.from_file("~/.config/nvim/snippets/global.json"),

                    -- Load snippets based on current language by reading files from
                    -- "snippets/" subdirectories from 'runtimepath' directories.
                    gen_loader.from_lang(),
                },
            })
        end,
    }
    {
        "hrsh7th/nvim-cmp",
        lazy = false,
        dependencies = {
            "xzbdmw/cmp_mini_snippets",
        },
        config = function(_, opts)
            local cmp = require("cmp")
            require("cmp").setup({
                snippet = {
                    expand = function(args)
                        local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
                        insert({ body = args.body })
                    end,
                },
                sources = require("cmp").config.sources({
                    { name = "mini_snippets" },
                }, {}),
            })
        end,
    },
```
