local map = vim.keymap.set

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  opts = {
    on_attach = function(bufnr)
      local api = require('nvim-tree.api')

      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      map('n', '<CR>', api.node.open.edit, opts('Open'))
      map('n', 'J', api.node.open.horizontal, opts('Open in horitzontal split'))
      map('n', 'L', api.node.open.vertical, opts('Open in vertical split'))
      map('n', 'K', api.node.show_info_popup, opts('Info'))
      map('n', 'R', api.tree.reload, opts('Refresh'))
      map('n', 'a', api.fs.create, opts('Create'))
      map('n', 'd', api.fs.remove, opts('Delete'))
      map('n', 'g?', api.tree.toggle_help, opts('Help'))
      map('n', 'p', api.fs.paste, opts('Paste'))
      map('n', 'r', api.fs.rename, opts('Rename'))
      map('n', 'x', api.fs.cut, opts('Cut'))

      -- Add mapping for mouse double-click to open files
      map('n', '<2-LeftMouse>', api.node.open.edit, opts('Open with mouse double-click'))
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
      custom = { "^\\.git$" , "node_modules", ".cache" } 
    },
    git = {
      ignore = false,
    },
  },
}
