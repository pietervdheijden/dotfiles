-- Configure tabs
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4

-- Configure mapping
local map = vim.keymap.set
local jdtls = require('jdtls')
map('n', '<leader>oi', jdtls.organize_imports, { desc = "JDTLS: organize imports" })

