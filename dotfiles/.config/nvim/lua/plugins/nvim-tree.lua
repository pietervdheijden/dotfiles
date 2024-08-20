return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  opts = {
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
      custom = { "^\\.git$" , "node_modules", ".cache" } 
    },
    git = {
      ignore = false,
    },
  },
  config = function()
    require("nvim-tree").setup(opts)

    -- Helper function to check if Neovim was opened by `kubectl edit`
    local function is_kubectl_edit()
      -- Check the command line arguments for "kubectl edit"
      local arglist = vim.fn.argv()
      for _, arg in ipairs(arglist) do
        if arg:match("kubectl") and arg:match("edit") then
          return true
        end
      end

      return false
    end

    -- Ensure nvim-tree tracks the open file
    vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "TabEnter"}, {
      callback = function()
        if not is_kubectl_edit() then
          require("nvim-tree.api").tree.find_file({ open = true })
        end  
      end,
    })
  end
}
