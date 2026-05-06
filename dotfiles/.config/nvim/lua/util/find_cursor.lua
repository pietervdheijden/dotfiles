local This = {}

local ns = vim.api.nvim_create_namespace("find_cursor_flash")
local augroup = vim.api.nvim_create_augroup("FindCursorFlash", { clear = true })

function This.flash()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  vim.api.nvim_clear_autocmds({ group = augroup })

  vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
    line_hl_group = "FindCursorFlash",
    priority = 200,
  })

  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI", "InsertEnter", "CmdlineEnter", "BufLeave", "WinLeave" },
    {
      group = augroup,
      once = true,
      callback = function()
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      end,
    }
  )
end

return This
