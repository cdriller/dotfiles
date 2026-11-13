_G.clang_format = function()
      local buf = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local out = vim.fn.systemlist(
        { "clang-format", "--assume-filename", vim.api.nvim_buf_get_name(buf) },
        lines
      )
      if vim.v.shell_error ~= 0 then return 1 end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
      return 0
    end
