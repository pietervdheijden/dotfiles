return {
  'rmagatti/auto-session',
  lazy = false,
  config = function()
    require("auto-session").setup({
      auto_restore_enabled = true,
      auto_save_enabled = true,
      auto_session_suppress_dirs = { "~/", "/" },
      post_restore_cmds = {
        function()
          -- Reopen nivm-tree after restoring session
          require('nvim-tree.api').tree.open()

          -- Return focus to buffer
          vim.cmd.wincmd('p')
        end
      },
    })
  end
}
