local This = {}

local map = vim.keymap.set

function This.setup()
  -- Telescope
  local telescope = require('telescope.builtin')
  map('n', '<leader>ff', telescope.find_files, { desc = "TS: Find files" })
  map('n', '<leader>fg', telescope.live_grep, { desc = "TS: Live grep" })
  map('n', '<leader>fb', telescope.buffers, { desc = "TS: Buffers" })
  map('n', '<leader>fh', telescope.help_tags, { desc = "TS: Help tags" })
  map('n', '<leader>fr', telescope.resume, { desc = "TS: Resume" })

  -- LazyVim
  map('n', '<leader>lv', ':Lazy<CR>', { desc = 'Open LazyVim' })

  -- LSP
  -- map('n', '<leader>gd', vim.lsp.buf.declaration, { buffer = bufnr, desc = 'go to declaration' })

  -- Other
  map('n', '<leader>qa', ':qa<CR>', { desc = 'Quit all' })
  map('n', '<leader>qf', ':copen<CR>', { desc = "Open Quickfix List" })
end

return This
