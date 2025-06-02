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
-- vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n"))
-- Only include actual OSGi bundles, not fat JARs or agents
local java_test_bundles = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n")
for _, bundle in ipairs(java_test_bundles) do
  if not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar") and
     not vim.endswith(bundle, "jacocoagent.jar") then
    -- print("Insert bundle: " .. bundle)
    table.insert(bundles, bundle)
  end
end

local home = vim.fn.expand("~")
local mason_path = install_path
local lombok_path = mason_path .. "/lombok.jar"
local workspace_path = home .. "/.local/share/nvim/java_workspace/"

-- Configure `nvim-jdtls`
local function config()
  -- Set JAVA_HOME environment variable
  vim.env.JAVA_HOME = '/usr/lib/jvm/java-21-openjdk'
  vim.env.PATH = vim.env.JAVA_HOME .. '/bin:' .. vim.env.PATH
  
  return {
    cmd = {
      -- install_path .. '/bin/jdtls',  -- Use Mason's wrapper script
      '/usr/lib/jvm/java-21-openjdk/bin/java',
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

      -- Use unique server instance
      '-Declipse.jdt.ls.vmargs=-Dfile.encoding=UTF-8',
      '-Djava.import.generatesMetadataFilesAtProjectRoot=false',

      '-jar', vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration', mason_path .. '/config_linux',
      '-data', workspace_path .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
    },
    root_dir = require('jdtls.setup').find_root({ '.git' }),
    settings = {
      java = {
        home = "/usr/lib/jvm/java-21-openjdk",
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
              name = "JavaSE-21",
              path = "/usr/lib/jvm/java-21-openjdk",
              default = true,
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
      bundles = bundles
    },
    -- on_init = function(client, _)
    --     client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
    -- end,
    on_attach = function(client, bufnr)
      require('config.mappings').setup_lsp(bufnr)
    end,
  }
end

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "java",
--   callback = function()
--     local jdtls_config = config()
--     local capabilities = vim.lsp.protocol.make_client_capabilities()
--     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
--     jdtls_config.capabilities = capabilities
--     -- require("jdtls").setup_dap({})
--     -- print("start jdtls: " .. os.date())
--     require("jdtls").start_or_attach(jdtls_config)
--   end,
--   group = vim.api.nvim_create_augroup("jdtls_setup", { clear = true }),
-- })

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "java",
--   callback = function()
--     -- Only start if no JDTLS client exists for this root
--     local root_dir = require('jdtls.setup').find_root({ '.git' })
--     local clients = vim.lsp.get_active_clients({ name = "jdtls" })
--
--     for _, client in ipairs(clients) do
--       if client.config.root_dir == root_dir then
--         print("JDTLS already running for workspace:", root_dir)
--         return
--       end
--     end
--
--     print("Starting JDTLS for workspace:", root_dir)
--     local jdtls_config = config()
--     local capabilities = vim.lsp.protocol.make_client_capabilities()
--     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
--     jdtls_config.capabilities = capabilities
--     require("jdtls").start_or_attach(jdtls_config)
--   end,
--   group = vim.api.nvim_create_augroup("jdtls_setup", { clear = true }),
-- })

-- Simple autocmd that lets nvim-jdtls handle everything
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "java",
--   callback = function()
--     local jdtls_config = config()
--     local capabilities = vim.lsp.protocol.make_client_capabilities()
--     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
--     jdtls_config.capabilities = capabilities
--     require("jdtls").start_or_attach(jdtls_config)
--   end,
--   group = vim.api.nvim_create_augroup("jdtls_setup", { clear = true }),
-- })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    -- Only start if no JDTLS client exists for this root
    local root_dir = require('jdtls.setup').find_root({ '.git' })
    local clients = vim.lsp.get_active_clients({ name = "jdtls" })

    for _, client in ipairs(clients) do
      if client.config.root_dir == root_dir then
        print("JDTLS already running for workspace:", root_dir)
        return
      end
    end

    print("Starting JDTLS for workspace:", root_dir)
    local jdtls_config = config()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    jdtls_config.capabilities = capabilities
    require("jdtls").start_or_attach(jdtls_config)
  end,
  group = vim.api.nvim_create_augroup("jdtls_setup", { clear = true }),
})

-- return {}
return {
  "mfussenegger/nvim-jdtls",
  ft = { 'java' },
  -- ft = "java",
  jdtls_config = config
}
