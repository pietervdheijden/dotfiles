local This = {}

function This.setup()
    -- Disable netrw to prevent race conditions at startup with nvimtree 
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- Disable optional providers
    vim.g.loaded_perl_provider = 0
    vim.g.loaded_python3_provider = 0
    vim.g.loaded_ruby_provider = 0

    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"

    vim.opt.expandtab = true
    vim.opt.tabstop = 2
end

return This
