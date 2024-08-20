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

        -- Configuration for automatically opening nvim-tree
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                if vim.fn.argc() == 0 then
                    require("nvim-tree.api").tree.open()
                end
            end
        })

        -- Ensure nvim-tree tracks the open file
        vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "TabEnter"}, {
            callback = function()
                require("nvim-tree.api").tree.find_file({ open = true })
            end,
        })
    end
}
