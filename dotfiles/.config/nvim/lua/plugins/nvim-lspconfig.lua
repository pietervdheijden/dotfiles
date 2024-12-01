return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    require('mason').setup()
    require('mason-lspconfig').setup({ 
      ensure_installed = {
        "jdtls",
        "pyright",
        "terraform-ls"
      },
      automatic_installation = true,
    })

    -- Automatically set up LSP servers
    require('mason-lspconfig').setup_handlers({
      -- Default handler for all installed servers
      function(server_name)
        require('lspconfig')[server_name].setup({})
      end,
      -- Add custom handlers if needed, e.g., for jdtls
      ["jdtls"] = function()
        require('lspconfig').jdtls.setup({
          -- Add your jdtls-specific settings here
        })
      end,
    })
  end
  --   local nvim_lsp = require('lspconfig')
  --
  --
  --
  --   -- Configure Pyright
  --   nvim_lsp.pyright.setup{
  --       on_attach = function(client, bufnr)
  --           -- Enable completion triggered by <c-x><c-o>
  --           vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  --
  --           -- Mappings.
  --           local opts = { noremap=true, silent=true }
  --           -- See `:help vim.lsp.*` for documentation on any of the below functions
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  --           -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
  --
  --           -- Reload diagnostics
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rd', '<cmd>lua vim.diagnostic.reset() vim.diagnostic.show()<CR>', opts)
  --       end,
  --       flags = {
  --           debounce_text_changes = 150,
  --       }
  --   }
  --
  --   local lombok_jar = os.getenv('HOME') .. '/.local/share/eclipse/lombok.jar'
  --   -- require('java').setup({
  --   --   javaAgent = lombok_jar,  -- Add Lombok agent
  --   --   jvmArgs = {
  --   --     '-Xms1g',
  --   --     '-Xmx2g',
  --   --     '-javaagent:' .. lombok_jar,
  --   --   },  
  --   -- })
  --   nvim_lsp.jdtls.setup({
  --       on_attach = function(client, bufnr)
  --           -- Enable completion triggered by <c-x><c-o>
  --           vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  --
  --           -- Mappings.
  --           local opts = { noremap=true, silent=true }
  --           -- See `:help vim.lsp.*` for documentation on any of the below functions
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  --           -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
  --
  --           -- Reload diagnostics
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rd', '<cmd>lua vim.diagnostic.reset() vim.diagnostic.show()<CR>', opts)
  --       end,
  --       flags = {
  --           debounce_text_changes = 150,
  --       }
  --   })
  --   -- local home = os.getenv('HOME')
  --   -- local lombok_jar = home .. '/.local/share/eclipse/lombok.jar'  -- Update this path
  --   --
  --   -- -- Configure jdtls for Java
  --   -- nvim_lsp.jdtls.setup{
  --   --     cmd = { 
  --   --       'jdtls',
  --   --       '-javaagent:' .. lombok_jar,
  --   --     },
  --   --     init_options = {
  --   --         bundles = {
  --   --             lombok_jar
  --   --         },
  --   --         vmargs = { '-javaagent:' .. lombok_jar },
  --   --
  --   --     },
  --   --     settings = {
  --   --         java = {
  --   --             home = '/usr/lib/jvm/java-23-openjdk/bin/java',
  --   --             -- home = '/home/linuxbrew/.linuxbrew/opt/openjdk@17/libexec',  -- Optional: specify your Java home
  --   --             use_lombok_agent = true,
  --   --             configuration = {
  --   --                 -- Specify the Lombok JAR in the Java runtime options
  --   --                 runtimes = {
  --   --                     -- {
  --   --                     --     name = 'JavaSE-1.8',
  --   --                     --     path = '/path/to/your/jdk1.8',
  --   --                     --     vmargs = { '-javaagent:' .. lombok_jar }
  --   --                     -- },
  --   --                     -- {
  --   --                     --     name = 'JavaSE-17',
  --   --                     --     path = '/home/linuxbrew/.linuxbrew/opt/openjdk@17/libexec',
  --   --                     --     vmargs = { '-javaagent:' .. lombok_jar }
  --   --                     -- }
  --   --                     {
  --   --                         name = 'JavaSE-23',
  --   --                         path = '/usr/lib/jvm/java-23-openjdk',
  --   --                         vmargs = { '-javaagent:' .. lombok_jar }
  --   --                     }
  --   --                 }
  --   --             }
  --   --         }
  --   --     },
  --   --     on_attach = function(client, bufnr)
  --   --         -- Enable completion triggered by <c-x><c-o>
  --   --         vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  --   --
  --   --         -- Mappings.
  --   --         local opts = { noremap=true, silent=true }
  --   --         -- See `:help vim.lsp.*` for documentation on any of the below functions
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  --   --         -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
  --   --
  --   --         -- Reload diagnostics
  --   --         vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rd', '<cmd>lua vim.diagnostic.reset() vim.diagnostic.show()<CR>', opts)
  --   --     end,
  --   --     flags = {
  --   --         debounce_text_changes = 150,
  --   --     }
  --   -- }
  --
  --   -- Configure Terraform
  --   nvim_lsp.terraformls.setup{
  --       on_attach = function(client, bufnr)
  --           -- Enable completion triggered by <c-x><c-o>
  --           vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  --
  --           -- Mappings.
  --           local opts = { noremap=true, silent=true }
  --           -- See `:help vim.lsp.*` for documentation on any of the below functions
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  --           -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
  --
  --           -- Reload diagnostics
  --           vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rd', '<cmd>lua vim.diagnostic.reset() vim.diagnostic.show()<CR>', opts)
  --       end,
  --       flags = {
  --           debounce_text_changes = 150,
  --       }
  --   }
  --   vim.api.nvim_create_autocmd({"BufWritePre"}, {
  --     pattern = {"*.tf", "*.tfvars"},
  --     callback = function()
  --       vim.lsp.buf.format()
  --     end,
  --   })
  -- end
}
