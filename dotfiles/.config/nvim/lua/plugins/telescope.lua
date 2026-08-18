return {
  'nvim-telescope/telescope.nvim',
  branch = 'master',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim'
  },
  config = function()
    local telescope = require('telescope')

    -- Directories/files to never show, even though we search ignored files.
    local excludes = {
      '--glob', '!.git',
      '--glob', '!node_modules',
      '--glob', '!.cache',
      '--glob', '!**/dist/**',
      '--glob', '!**/build/**',
      '--glob', '!**/target/**',
    }

    telescope.setup({
      defaults = {
        vimgrep_arguments = vim.list_extend({
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',     -- include dotfiles (e.g. .env)
          '--no-ignore',  -- also search git-ignored files
        }, vim.deepcopy(excludes)),
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
          find_command = vim.list_extend({
            'rg',
            '--files',
            '--hidden',     -- include dotfiles (e.g. .env)
            '--no-ignore',  -- also list git-ignored files
          }, vim.deepcopy(excludes)),
        },
      }
    })

    telescope.load_extension('ui-select')
  end
}
