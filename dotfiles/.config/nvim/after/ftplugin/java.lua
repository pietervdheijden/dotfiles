-- Configure tabs
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4

-- Locals
local map = vim.keymap.set
local jdtls = require('jdtls')

-- Refactoring mapping
map('n', '<leader>oi', jdtls.organize_imports, { desc = "JDTLS: organize imports" })
map('n', '<leader>ev', jdtls.extract_variable, { desc = "JDTLS: extract variable" })
map('n', '<leader>ec', jdtls.extract_constant, { desc = "JDTLS: extract constant" })
map('n', '<leader>em', jdtls.extract_method, { desc = "JDTLS: extract method" })

-- Test mapping
map('n', '<leader>tc', jdtls.test_class, { desc = "JDTLS: test class" })
map('n', '<leader>tnm', jdtls.test_nearest_method, { desc = "JDTLS: test nearest method" })
