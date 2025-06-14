local This = {}

function This.setup()
  -- Disable netrw to prevent race conditions at startup with nvimtree
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- Disable optional providers
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_python3_provider = 0
  vim.g.loaded_ruby_provider = 0

  -- Configure leader
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  -- Configure tabs
  vim.opt.expandtab = true
  vim.opt.tabstop = 2
  vim.opt.softtabstop = 2
  vim.opt.shiftwidth = 2

  -- Configure line numbers
  vim.opt.number = true
  vim.opt.relativenumber = false

  -- Configure winbar
  vim.o.winbar = '%=%m %{v:lua.require("util.winbar").get_winbar()}'

  -- Configure bufferline
  vim.opt.termguicolors = true

  -- Configure splitright
  vim.opt.splitright = true

  -- Configure clipboard
  vim.opt.clipboard:append("unnamedplus")

  -- Configure colorcolumn
  vim.opt.colorcolumn = "120"

  -- Set filetype to 'sh' based on shebang for shell scripts without .sh extension
  vim.filetype.add({
    pattern = {
      ['.*'] = function(_, bufnr)
        local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
        if first_line:match("^#!.*/bin/bash")
            or first_line:match("^#!.*/usr/bin/env%s+bash")
            or first_line:match("^#!.*/bin/sh")
            or first_line:match("^#!.*/usr/bin/env%s+sh")
        then
          return "sh"
        end
      end,
    },
  })
end

return This
