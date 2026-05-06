return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim'
  },
  config = function()
    local telescope = require('telescope')
    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--no-ignore',
          '--glob', '!.git',
        },
        path_display = function(opts, path)
          local tail = require("telescope.utils").path_tail(path)
          return string.format("%s - %s", tail, path)
        end,
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            width = 0.85,
            height = 0.85,
            preview_width = 0.55,
            prompt_position = 'top',
          },
          vertical = {
            width = 0.85,
            height = 0.85,
            preview_height = 0.5,
            prompt_position = 'top',
          },
        },
        sorting_strategy = 'ascending',
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      },
      pickers = {
        find_files = {
          find_command = {
            'rg',
            '--files',
            '--hidden',
            '--no-ignore',
            '--glob', '!.git',
          },
        },
      }
    })

    telescope.load_extension('ui-select')
  end
}
