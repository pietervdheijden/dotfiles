local This = {}

local map = vim.keymap.set

function This.setup()
    map('n', '<leader>fn', vim.cmd.NvimTreeFindFileToggle, { desc = 'open file tree' })
end

return This
