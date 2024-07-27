local This = {}

function This.setup()
    -- Disable netrw to prevent race conditions at startup with nvimtree 
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"
end

return This
