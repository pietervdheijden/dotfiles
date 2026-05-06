return { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000,
    opts = {
      custom_highlights = function(colors)
        return {
          CursorLineNr = { fg = colors.yellow, bold = true },
          FindCursorFlash = { bg = colors.yellow, fg = colors.base, bold = true },
        }
      end,
      integrations = {
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = {
          enabled = true
        },
        which_key = true,
        noice = true,
      }
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end
}
