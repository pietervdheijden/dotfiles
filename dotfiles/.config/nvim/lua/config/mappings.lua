local This = {}

local map = vim.keymap.set

function This.setup()
  -- Nvim-tree  
  map('n', '<leader>fn', vim.cmd.NvimTreeFindFileToggle, { desc = 'open file tree' })

  -- Telescope
  local telescope = require('telescope.builtin')
  map('n', '<leader>ff', telescope.find_files, { desc = "TS: Find files" })
  map('n', '<leader>fg', telescope.live_grep, { desc = "TS: Live grep" })
  map('n', '<leader>fb', telescope.buffers, { desc = "TS: Buffers" })
  map('n', '<leader>fh', telescope.help_tags, { desc = "TS: Help tags" })
  map('n', '<leader>fr', telescope.resume, { desc = "TS: Resume" })

  -- LazyVim
  map('n', '<leader>ln', ':Lazy<CR>', { desc = 'Open LazyVim' })

  -- Other
  map('n', '<leader>qa', ':qa<CR>', { desc = 'Quit all' })
end

return This
