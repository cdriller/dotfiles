local vim = vim
local lsp = vim.lsp

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function (args)
        require "keys".lsp_attach_evect(args)
        vim.bo[args.buf].formatexpr = "v:lua.vim.lsp.formatexpr()"
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function (args)
        vim.bo[args.buf].formatexpr = nil
    end,
})

--- @param lsps table lsp service declarations
local function load_lsps(lsps)
    for _, pair in ipairs(lsps) do
        lsp.config[pair.name] = pair.config or {}
        lsp.enable(pair.name)
    end
end


load_lsps {
    {
        name = "clangd",
        config = {
            cmd = {
                "clangd",
                "--clang-tidy",
                "--background-index",
                "--offset-encoding=utf-8",
            },
            root_markers = {},
            filetypes = { "c", "cpp", "h", "hpp" },
        },
    },
    {
        name = "html",
        config = {
            cmd = { "vscode-html-language-server", "--stdio" },
        },
    },
    { name = "lua_ls",
        config = {
            on_init = function (client)
                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if
                        path ~= vim.fn.stdpath("config")
                        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
                    then
                        return
                    end
                end
                -- lua language server is super confused when editing lua files in the config
                -- and raises a lot of [duplicate-doc-field] warnings
                local runtime_files = vim.api.nvim_get_runtime_file("", true)
                local config_path = vim.fn.stdpath("config")
                for k, v in ipairs(runtime_files) do
                    if v == config_path .. "/after" or v == config_path then
                        table.remove(runtime_files, k)
                    end
                end

                table.insert(runtime_files, "${3rd}/luv/library")

                client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most
                        -- likely LuaJIT in the case of Neovim)
                        version = "LuaJIT",
                        -- Tell the language server how to find Lua modules same way as Neovim
                        -- (see `:h lua-module-load`)
                        path = {
                            "lua/?.lua",
                            "lua/?/init.lua",
                        },
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = runtime_files,
                    },
                })
            end,
            settings = {
                Lua = {},
            },
        },
    },
    { name = "rust_analyzer" },
    { name = "jdtls" },
    { name = "pyright" },
}
