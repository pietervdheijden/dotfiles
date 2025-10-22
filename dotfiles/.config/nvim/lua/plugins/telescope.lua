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
          theme = 'ivy',
          previewer = false,
        },
        live_grep = {
          theme = 'ivy',
        }
      }
    })

    telescope.load_extension('ui-select')
  end
}
