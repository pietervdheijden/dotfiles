local install_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local debug_install_path = vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter'
local bundles = {
  vim.fn.glob(debug_install_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}

-- Configure java test
local java_test_path = vim.fn.stdpath('data') .. '/mason/packages/java-test'
vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n"))

local home = vim.fn.expand("~")
local lombok_path = install_path .. "/lombok.jar"
local workspace_path = home .. "/.local/share/nvim/java_workspace/"

local function jdtls_config(capabilities)
  return {
    cmd = {
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

      '-jar', vim.fn.glob(install_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration', install_path .. '/config_linux',
      '-data', workspace_path .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
    },
    root_dir = require('jdtls.setup').find_root({ '.git' }),
    capabilities = capabilities,
    settings = {
      java = {
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
  }
end

return {
  "mfussenegger/nvim-jdtls",
  ft = { 'java' },
  jdtls_config = jdtls_config
}

