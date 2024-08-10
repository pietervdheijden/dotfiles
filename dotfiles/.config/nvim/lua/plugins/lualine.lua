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
          function()
            -- Get the current file path
            local filepath = vim.fn.expand('%:p')
            if filepath == '' then
              return ''
            end

            -- Get the git status for the file
            local git_status = vim.fn.systemlist('git ls-files --others --exclude-standard ' .. filepath)
            if #git_status > 0 then
              return 'Untracked'
            end

            return ''
          end,
          color = { fg = '#ff0000' }, -- Customize the color for untracked files
        },
        'diagnostics'
      },
      lualine_c = { 
        {
          'filename',
          path = 1,
        },
      },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' }
    },
  },
}

