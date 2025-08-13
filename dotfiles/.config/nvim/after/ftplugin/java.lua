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
vim.keymap.set('n', '<leader>tm', function()
  vim.g.jdtls_last_test = {
    file = vim.fn.expand('%:p'),
    line = vim.fn.line('.'),
    col = vim.fn.col('.'),
    type = 'method'
  }
  require('jdtls').test_nearest_method()
end, { desc = "JDTLS: test nearest method" })

vim.keymap.set('n', '<leader>tc', function()
  vim.g.jdtls_last_test = {
    file = vim.fn.expand('%:p'),
    line = vim.fn.line('.'),
    col = vim.fn.col('.'),
    type = 'class'
  }
  require('jdtls').test_class()
end, { desc = "JDTLS: test class" })

vim.keymap.set('n', '<leader>tl', function()
  if vim.g.jdtls_last_test then
    -- Store current location
    local current_buf = vim.api.nvim_get_current_buf()
    local current_pos = vim.api.nvim_win_get_cursor(0)

    -- Temporarily switch to test file
    vim.cmd('edit ' .. vim.g.jdtls_last_test.file)
    vim.fn.cursor(vim.g.jdtls_last_test.line, vim.g.jdtls_last_test.col)

    -- Run the test
    if vim.g.jdtls_last_test.type == 'method' then
      require('jdtls').test_nearest_method()
    elseif vim.g.jdtls_last_test.type == 'class' then
      require('jdtls').test_class()
    end

    -- Switch back to original location
    vim.api.nvim_set_current_buf(current_buf)
    vim.api.nvim_win_set_cursor(0, current_pos)
  else
    vim.notify("No previous test to run", vim.log.levels.WARN)
  end
end, { desc = "JDTLS: run last test" })
