return {
    'nvim-telescope/telescope.nvim', 
    tag = '0.1.8',
    dependencies = { 
        'nvim-lua/plenary.nvim'
    },
    config = function()
        local telescope = require('telescope')
        telescope.setup({
            defaults = {
                vimgrep_arguments = {
                    'rg', '--color=never', '--no-heading', '--with-filename',
                    '--line-number', '--column', '--smart-case', '--hidden',
                    "-g", "!.git"
                },
                path_display = function(opts, path)
                  local tail = require("telescope.utils").path_tail(path)
                  return string.format("%s - %s", tail, path)
                end,
                dynamic_preview_title = true,
            },
            pickers = {
                find_files = {
                    find_command = {'rg', '--files', '--hidden', '-g', '!.git'},
                }
            }
        }) 
    end
}
