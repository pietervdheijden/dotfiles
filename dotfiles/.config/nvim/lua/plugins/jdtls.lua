local install_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
-- local install_path = require("mason-registry").get_package("jdtls"):get_install_path()
-- get the debug adapter install path
local debug_install_path = vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter'
-- local debug_install_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()
local bundles = {
  vim.fn.glob(debug_install_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}

-- Configure java test
local java_test_path = vim.fn.stdpath('data') .. '/mason/packages/java-test'
vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n"))

local home = vim.fn.expand("~")
local mason_path = install_path
local lombok_path = mason_path .. "/lombok.jar"
local workspace_path = home .. "/.local/share/nvim/java_workspace/"

-- Configure `nvim-jdtls`
local function config()
  return {
    cmd = {
      '/usr/lib/jvm/java-24-openjdk/bin/java',
      '-javaagent:' .. lombok_path,
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xms1g',
      '-XX:+UseG1GC',  -- Add this for better GC
      '-XX:+UseStringDeduplication',  -- Add this for better memory usage
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-jar', vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration', mason_path .. '/config_linux',
      '-data', workspace_path .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
    },
      -- local on_attach = function(client, bufnr)
      --   require("plugins.lspconfig").on_attach(client, bufnr)
      -- end
      --
      -- local capabilities = require("plugins.lspconfig").capabilities
    -- on_attach = on_attach,
    -- capabilities = capabilities,
    root_dir = require('jdtls.setup').find_root({ '.git' }),
    settings = {
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
      java = {
        format = {
          enabled = true,
          -- settings = {
          --   -- Use Google Java style guidelines for formatting
          --   -- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
          --   -- and place it in the ~/.local/share/eclipse directory
          --   url = "/.local/share/eclipse/eclipse-java-google-style.xml",
          --   profile = "GoogleStyle",
          -- },
        },
        saveActions = {
          organizeImports = true,
        },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },  -- Use fernflower to decompile library code
        -- Specify any completion options
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*"
          },
          filteredTypes = {
            "com.sun.*",
            "io.micrometer.shaded.*",
            "java.awt.*",
            "jdk.*", "sun.*",
          },
        },
        -- Specify any options for organizing imports
        sources = {
          organizeImports = {
            starThreshold = 9999;
            staticStarThreshold = 9999;
          },
        },
        -- How code generation should act
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
          },
          hashCodeEquals = {
            useJava7Objects = true,
          },
          useBlocks = true,
        },
        configuration = {
          updateBuildConfiguration = "automatic",
          runtimes = {
            {
              name = "JavaSE-11",
              path = "/usr/lib/jvm/java-11-openjdk",
            },
            {
              name = "JavaSE-17",
              path = "/usr/lib/jvm/java-17-openjdk",
            },
            {
              name = "JavaSE-24",
              path = "/usr/lib/jvm/java-24-openjdk",
            }
          }
        },
        maven = {
          downloadSources = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        references = {
          includeDecompiledSources = true,
        },
        import = {
          gradle = {
            enabled = true
          },
          maven = {
            enabled = true
          },
          timeout = 180
        },
        project = {
          referencedLibraries = {},
        }
      },
    },
    init_options = {
      bundles = {
        vim.fn.glob(home .. '/.config/nvim/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'),
        unpack(vim.fn.glob(home .. '/.config/nvim/vscode-java-test/server/*.jar', 1, 1)),
      },
    },
  -- Add this to ensure proper project configuration
      on_init = function(client, _)
          client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
      end,
    on_attach = function(client, bufnr)
      require('config.mappings').setup_lsp(bufnr)
    end,
  }
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local jdtls_config = config()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    jdtls_config.capabilities = capabilities
    require("jdtls").start_or_attach(jdtls_config)
  end,
})

return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
}
