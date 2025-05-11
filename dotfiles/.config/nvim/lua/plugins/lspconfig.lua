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
