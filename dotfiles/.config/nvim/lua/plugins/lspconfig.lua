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
              -- Enable completion triggered by <c-x><c-o>
              vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

              -- Helper function for creating keymaps
              function nnoremap(rhs, lhs, bufopts, desc)
                bufopts.desc = desc
                vim.keymap.set("n", rhs, lhs, bufopts)
              end

              -- Mappings.
              local function opts(desc)
                return { desc = 'LSP: ' .. desc, noremap = true, silent = true }
              end
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              nnoremap('gD', vim.lsp.buf.declaration, bufopts, 'Go to declaration')
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts('Go to definition'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts('Go to implementation'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts('Hover text'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts('Show signature'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts('Add workspace folder'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts('Remove workspace folder'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts('List workspace folders'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts('Go to type definition'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts('Rename'))
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts('Find refenerences'))
              nnoremap('<space>ca', vim.lsp.buf.code_action, bufopts, "Code actions")
              vim.keymap.set('v', "<space>ca", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
                 { noremap=true, silent=true, buffer=bufnr, desc = "Code actions" })
              -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
              -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts('Format file'))

              -- Reload diagnostics
              -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rd', '<cmd>lua vim.diagnostic.reset() vim.diagnostic.show()<CR>', opts)
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
