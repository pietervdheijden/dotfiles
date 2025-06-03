local map = vim.keymap.set

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)

    local api = require("nvim-tree.api")

    map('n', '<leader>fn', function()
      api.tree.toggle({ find_file = true })
    end, { desc = 'open file tree and file file' })

    map('n', '<leader>e', function()
      local nvim_tree_focused = vim.api.nvim_get_current_win() == require('nvim-tree.view').get_winnr()
      if nvim_tree_focused then
        vim.cmd.wincmd('p') -- Go to previous window
      else
        api.tree.focus()
      end
    end, { desc = 'toggle focus between editor and file tree' })
  end,
  opts = {
    on_attach = function(bufnr)
      require('config.mappings').setup_nvimtree(bufnr)
    end,
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      adaptive_size = true,
    },
    update_focused_file = {
      enable = true
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
      custom = { "^\\.git$", "node_modules", ".cache" }
    },
    git = {
      ignore = false,
    },
    auto_reload_on_write = true,
  },
}
