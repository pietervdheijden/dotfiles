return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    require('mason').setup()
    require('mason-tool-installer').setup {
      ensure_installed = {
        -- LSP
        'jdtls',
        'pyright',
        'terraformls',

        -- DAP
        'java-debug-adapter',
        'java-test',
      }
    }
    require('mason-lspconfig').setup({
      handlers = {
        -- Default handler for all installed servers
        function(server_name)
          if server_name == 'jdtls' then
            -- These require specialized setup
            return
          end
          require('lspconfig')[server_name].setup({
            on_attach = function(client, bufnr)
              require('config.mappings').setup_lsp(bufnr)
            end,
            flags = {
              debounce_text_changes = 150,
            }
          })
        end,
        -- Add custom handlers if needed, e.g., for jdtls
        -- ["jdtls"] = function()
        --   require('lspconfig').jdtls.setup({
        --     -- Add your jdtls-specific settings here
        --   })
        -- end,
  
        -- Java extensions provided by jdtls
        -- nnoremap("<C-o>", jdtls.organize_imports, bufopts, "Organize imports")
        -- nnoremap("<space>ev", jdtls.extract_variable, bufopts, "Extract variable")
        -- nnoremap("<space>ec", jdtls.extract_constant, bufopts, "Extract constant")
        -- vim.keymap.set('v', "<space>em", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
        --   { noremap=true, silent=true, buffer=bufnr, desc = "Extract method" })
        --     }
    -- })
-- " If using nvim-dap
-- " This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
-- nnoremap <leader>df <Cmd>lua require'jdtls'.test_class()<CR>
-- nnoremap <leader>dn <Cmd>lua require'jdtls'.test_nearest_method()<CR>
      }
    })

    -- Auto format on save
    vim.api.nvim_create_autocmd({"BufWritePre"}, {
      pattern = {"*.tf", "*.tfvars"},
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end
}
