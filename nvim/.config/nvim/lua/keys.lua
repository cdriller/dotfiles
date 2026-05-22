local M = {}


M.gitsigns = function (bufnr)
    local gitsigns = require("gitsigns")
    local wk = require("which-key")

    local function map(mode, l, r, opts)
        opts = opts or {}
        wk.add({
            l,
            r,
            mode = mode,
            buffer = bufnr,
            desc = opts.desc,
        })
    end

    map("n", "]c", function ()
        if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
        else
            gitsigns.nav_hunk("next")
        end
    end)

    map(
        "n",
        "[c", function ()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gitsigns.nav_hunk("prev")
            end
        end
    )

    wk.add({ "<leader>h", group = "Hunk" })
    -- Actions
    map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage Hunk" })
    map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset Hunk" })

    map(
        "v", "<leader>hs",
        function ()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        { desc = "Stage Hunk" }
    )

    map("v", "<leader>hr", function ()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "Reset Hunk" })

    map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview Hunk" })
    map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "Preview Hunk inline" })

    map("n", "<leader>hb", function ()
        gitsigns.blame_line({ full = true })
    end, { desc = "Blame line" })

    map("n", "<leader>hd", gitsigns.diffthis)

    map("n", "<leader>hD", function ()
        gitsigns.diffthis("~")
    end)

    map("n", "<leader>hQ", function () gitsigns.setqflist("all") end)
    map("n", "<leader>hq", gitsigns.setqflist)

    -- Toggles
    map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
    -- map("n", "<leader>tw", gitsigns.toggle_word_diff)

    -- Text object
    map({ "o", "x" }, "ih", gitsigns.select_hunk)
end

-- Bug: Funktioniert grade nicht
local function source_current_function()
    local ts_utils = require("nvim-treesitter.ts_utils")
    local node = ts_utils.get_node_at_cursor()

    while node do
        local type = node:type()
        if type == "function_definition" or
            type == "function_declaration" or
            type == "local_function" then
            break
        end
        node = node:parent()
    end

    if not node then
        vim.notify("Keine Funktion gefunden", vim.log.levels.WARN)
        return
    end

    -- Get the body node instead of the whole function
    local body = node:field("body")[1]
    if not body then
        vim.notify("Kein Funktions-Body gefunden", vim.log.levels.WARN)
        return
    end

    local start_row, _, end_row, _ = body:range()
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    local source = table.concat(lines, "\n")

    vim.notify(source)
    load(source, "test", "t", _G)()
end

M.lsp_attached = function (args)
    vim.keymap.set("n", "grc", vim.lsp.buf.declaration)
    vim.keymap.set("n", "grd", vim.lsp.buf.definition)

    local wk = require("which-key")
    wk.add { { "gQ", function () vim.lsp.buf.format() end, desc = "Format with lsp", buffer = args.buf } }
end

M.global = function ()
    vim.keymap.set("n", "]]", "]]zz", { silent = true, noremap = true })
    vim.keymap.set("n", "[[", "[[zz", { silent = true, noremap = true })
    vim.keymap.set("n", "[]", "[]zz", { silent = true, noremap = true })
    vim.keymap.set("n", "][", "][zz", { silent = true, noremap = true })
    vim.keymap.set("n", "[c", "[czz", { silent = true, noremap = true })
    vim.keymap.set("n", "]c", "]czz", { silent = true, noremap = true })
    vim.keymap.set("n", "<C-]>", "<C-]>zz", { silent = true, noremap = true })

    local wk = require("which-key")
    local fzf = require("fzf-lua")
    wk.add {
        { "<leader>f",        fzf.files,                                                              desc = "Find files in this directory" },

        -- nvim
        { "<leader>n",        group = "nvim" },
        { "<leader>ni",       ":e ~/.config/nvim/init.lua<cr>",                                       desc = "Open nvim init.lua" },
        { "<leader>np",       function () fzf.files({ cwd = "$HOME/.config/nvim/lua/plugins/" }) end, desc = "Search for nvim plugin config" },
        { "<leader>nk",       ":e ~/.config/nvim/lua/keys.lua<cr>",                                   desc = "Open nvim keys config" },

        -- other configs
        { "<leader>,",        group = "config" },

        -- Execute File
        { "<leader><CR>",     group = "Run ..." },
        { "<leader><CR>i",    group = "Run inner ..." },
        { "<leader><CR><CR>", ":source %<CR>",                                                        desc = "Nvim source file" },
        { "<leader><CR>if",   source_current_function,                                                desc = "Nvim source inner function" },
        { "<leader><CR><CR>", ":'<,'>source<CR>",                                                     mode = "v",                            desc = "Nvim source selection" },
        { "<leader><leader>", ":w<CR>",                                                               mode = "n",                            noremap = true,                silent = true },
        { "<leader>b",        fzf.buffers,                                                            mode = "n",                            noremap = true,                silent = true },
        { "<leader>f",        fzf.files,                                                              mode = "n",                            noremap = true,                silent = true, desc = "Find files in this directory" },
        { "<leader>g",        fzf.files,                                                              mode = "n",                            noremap = true,                silent = true, desc = "Find files in this directory" },
    }
end

return M
