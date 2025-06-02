local ensure_installed = {
  -- LSP
  'angular-language-server',
  'jdtls',
  'pyright',
  'terraformls',
  'typescript-language-server',
  'lua-language-server',

  -- DAP
  'java-debug-adapter',
  'java-test',
}

local function lsp_java_config(capabilities)
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('lsp_define_java', { clear = true }),
    pattern = 'java',
    callback = function()
      require('jdtls').start_or_attach(require('plugins.jdtls').jdtls_config(capabilities))
    end
  })
end

local function lsp_on_write()
  -- Auto format on save
  vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    callback = function()
      vim.lsp.buf.format()
    end,
  })
end

local function lsp_on_attach()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspAttachGroup', { clear = true }),
    callback = function(event)
      require('config.mappings').setup_lsp(event.buf)
    end
  })
end

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'terramate-io/vim-terramate', -- terramate-ls cannot (yet) be installed with mason
  },
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    require('mason').setup()
    require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
    require('mason-lspconfig').setup({
      automatic_enable = {
        exclude = { 'jdtls' }
      },
      ensure_installed = {}
    })

    lsp_java_config(capabilities)
    lsp_on_write()
    lsp_on_attach()
  end
}
