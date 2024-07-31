return { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000,
    opts = {
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
    config = function () 
      vim.cmd.colorscheme "catppuccin"
    end
}
