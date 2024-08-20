return {
  'akinsho/bufferline.nvim', 
  version = "*", 
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function () 
    require("bufferline").setup{
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
          reveal = {'close'}
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
        always_show_bufferline = true,
      },
    }

    -- Custom function to delete buffer and avoid focusing on Nvim Tree
    _G.delete_buffer = function()
      local bufnr = vim.fn.bufnr()
      -- Cycle to the next buffer
      vim.cmd('BufferLineCycleNext')
      -- Check if the new buffer is Nvim Tree
      if vim.bo.filetype == "NvimTree" then
        -- If it is, cycle again to avoid Nvim Tree
        vim.cmd('BufferLineCycleNext')
      end
      -- Finally, delete the original buffer
      vim.cmd('bdelete! '..bufnr)
    end

    -- Key mappings for deleting buffers
    vim.keymap.set('n', '<leader>bd', ':lua delete_buffer()<CR>', { noremap = true, silent = true, desc = "Delete buffer" })
  end,
}
