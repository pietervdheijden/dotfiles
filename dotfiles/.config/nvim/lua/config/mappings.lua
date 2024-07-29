local This = {}

local map = vim.keymap.set

function This.setup()
    map('n', '<leader>fn', vim.cmd.NvimTreeFindFileToggle, { desc = 'open file tree' })

    -- Telescope
    local builtin = require('telescope.builtin')
    map('n', '<leader>ff', builtin.find_files, { desc = "TS: Find files" })
    map('n', '<leader>fg', builtin.live_grep, { desc = "TS: Live grep" })
    map('n', '<leader>fb', builtin.buffers, { desc = "TS: Buffers" })
    map('n', '<leader>fh', builtin.help_tags, {desc = "TS: Help tags" })
end

return This
