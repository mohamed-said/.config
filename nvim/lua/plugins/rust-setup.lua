return {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
    config = function()
        vim.g.rustaceanvim = {
            -- Plugin configuration
            tools = {},
            -- LSP configuration
            server = {
                on_attach = function(client, bufnr)
                    -- you can also put keymaps in here
                end,
                default_settings = {
                    -- rust-analyzer language server configuration
                    ["rust-analyzer"] = {
                        procMacro = { enable = true },
                        hoverActions = { references = false },
                        inlayHints = {
                            enable = true, -- Enable inlay hints
                            typeHints = true, -- Show type hints
                            parameterHints = true, -- Show parameter hints
                        },
                    },
                },
            },
            -- DAP configuration
            dap = {},
        }
    end,
}
