-- Autocommand to update untracked status only on save or load
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  pattern = "*",
  callback = function()
    local filepath = vim.fn.expand('%:p')
    if filepath == '' then
      vim.b.untracked_status = ''
      return
    end

    -- Check if the file is untracked
    local git_status = vim.fn.systemlist('git ls-files --others --exclude-standard ' .. filepath)
    if #git_status > 0 then
      vim.b.untracked_status = 'Untracked'
    else
      vim.b.untracked_status = ''
    end
  end,
})

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      icons_enabled = true,
      globalstatus = true,
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        'branch',
        {
          'diff',
          symbols = { added = '+', modified = '~', removed = '-' },
        },
        {
          -- Show untracked status
          function()
            return vim.b.untracked_status or ''
          end,
          color = { fg = '#ff0000' },
        },
        'diagnostics'
      },
      lualine_c = {
        {
          function()
            return require("util.winbar").get_winbar()
          end
        }
      },
      lualine_x = {
        {
          function()
            if vim.g.jdtls_last_test then
              local class_name = vim.fn.fnamemodify(vim.g.jdtls_last_test.file, ':t:r')

              if vim.g.jdtls_last_test.type == 'method' and vim.g.jdtls_last_test.method_name then
                return '🧪 ' .. class_name .. '.' .. vim.g.jdtls_last_test.method_name .. '()'
                -- return '🔬 ' .. vim.g.jdtls_last_test.method_name .. ' (' .. filename .. ')'
              elseif vim.g.jdtls_last_test.type == 'class' then
                return '🧪 ' .. class_name
                -- return '📝 ' .. filename
              end
            end
            return ''
          end,
          color = { fg = '#98c379' }, -- Optional: green color
        },
        'encoding',
        'fileformat',
        'filetype'
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' }
    },
  },
}
