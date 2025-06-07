return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup {
      options = {
        indicator = {
          style = "underline",
        },
        separator_style = "slant",
        themeable = true,
        show_close_icon = false,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' }
        },
        color_icons = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true
          }
        },
        always_show_bufferline = false,
      },
    }
  end,
}
