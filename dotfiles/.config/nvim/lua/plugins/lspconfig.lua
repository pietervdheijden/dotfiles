return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'terramate-io/vim-terramate', -- terramate-ls cannot (yet) be installed with mason 
  },
  config = function()
    require('mason').setup()
    require('mason-tool-installer').setup {
      ensure_installed = {
        -- LSP
        'angular-language-server',
        'jdtls',
        'pyright',
        'terraformls',
        'typescript-language-server',

        -- DAP
        'java-debug-adapter',
        'java-test',
      }
    }
    require('mason-lspconfig').setup({
      handlers = {
        -- Default handler for all installed servers
        function(server_name)
          print("register handler for server_name: " .. server_name) 
          if server_name == 'jdtls' then
            -- These require specialized setup
            return
          end
          if server_name == 'java-debug-adapter' then
            return
          end
          if server_name == 'java-test' then
            return
          end
          require('lspconfig')[server_name].setup({
            on_attach = function(client, bufnr)
              print("attach :" .. server_name)
              require('config.mappings').setup_lsp(bufnr)
            end,
            flags = {
              debounce_text_changes = 150,
            }
          })
        end,
      },
      automatic_enable = {
        exclude = { 'jdtls' }
      },
    })

    -- vim.api.nvim_create_autocmd('FileType', {
    --     group = vim.api.nvim_create_augroup('lsp_define_java', { clear = true }),
    --     pattern = 'java',
    --     callback = function()
    --         print("Start jdtls")
    --         require('jdtls').start_or_attach(require('plugins.jdtls').jdtls_config())
    --     end
    -- })
    --
    -- Auto format on save
    vim.api.nvim_create_autocmd({"BufWritePre"}, {
      pattern = {"*.tf", "*.tfvars"},
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end
}
