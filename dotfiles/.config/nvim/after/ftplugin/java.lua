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
local function get_current_method_name()
  local ts_ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
  if not ts_ok then
    -- Fallback to word under cursor if treesitter not available
    return vim.fn.expand('<cword>')
  end

  local node = ts_utils.get_node_at_cursor()
  if not node then return nil end

  -- Walk up the tree to find method declaration
  while node do
    if node:type() == 'method_declaration' then
      for child in node:iter_children() do
        if child:type() == 'identifier' then
          return vim.treesitter.get_node_text(child, 0)
        end
      end
    end
    node = node:parent()
  end

  -- Fallback to word under cursor
  return vim.fn.expand('<cword>')
end

-- Updated test mappings
vim.keymap.set('n', '<leader>tm', function()
  local method_name = get_current_method_name()
  vim.g.jdtls_last_test = {
    file = vim.fn.expand('%:p'),
    line = vim.fn.line('.'),
    col = vim.fn.col('.'),
    type = 'method',
    method_name = method_name
  }
  require('jdtls').test_nearest_method()
end, { desc = "JDTLS: test nearest method" })

vim.keymap.set('n', '<leader>tc', function()
  vim.g.jdtls_last_test = {
    file = vim.fn.expand('%:p'),
    line = vim.fn.line('.'),
    col = vim.fn.col('.'),
    type = 'class'
    -- No method_name for class tests
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
