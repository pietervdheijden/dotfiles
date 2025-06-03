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
        always_show_bufferline = false,
      },
    }

    -- Custom function to delete buffer and avoid focusing on Nvim Tree
    _G.delete_current_buffer = function()
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

    -- Custom function to delete all buffers except current
    _G.delete_other_buffers = function()
      local current_buf = vim.api.nvim_get_current_buf()
      local buffers = vim.api.nvim_list_bufs()

      for _, buf in ipairs(buffers) do
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local is_nvim_tree = string.match(buf_name, "NvimTree_")

        if vim.api.nvim_buf_is_loaded(buf) and buf ~= current_buf and not is_nvim_tree then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end

    -- Custom function to delete all buffers to the left
    _G.delete_left_buffers = function()
      local current_buf = vim.api.nvim_get_current_buf()
      local buffers = vim.api.nvim_list_bufs()
      local current_buf_num = vim.fn.bufnr()

      for _, buf in ipairs(buffers) do
        local buf_num = vim.fn.bufnr(buf)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local is_nvim_tree = string.match(buf_name, "NvimTree_")

        if vim.api.nvim_buf_is_loaded(buf) and buf_num < current_buf_num and not is_nvim_tree then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end

    -- Custom function to delete all buffers to the right
    _G.delete_right_buffers = function()
      local current_buf = vim.api.nvim_get_current_buf()
      local buffers = vim.api.nvim_list_bufs()
      local current_buf_num = vim.fn.bufnr()

      for _, buf in ipairs(buffers) do
        local buf_num = vim.fn.bufnr(buf)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local is_nvim_tree = string.match(buf_name, "NvimTree_")

        if vim.api.nvim_buf_is_loaded(buf) and buf_num > current_buf_num and not is_nvim_tree then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end

  end,
}
