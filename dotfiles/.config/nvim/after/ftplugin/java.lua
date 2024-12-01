-- Configure tabs
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4


local jdtls = require('jdtls')

local home = vim.fn.expand("~")
local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
-- local lombok_path = home .. "/.config/nvim/lombok/lombok.jar"
local lombok_path = mason_path .. "/lombok.jar"

-- Define workspace path
local workspace_path = home .. "/.local/share/nvim/java_workspace/"

print(lombok_path)

-- Configure `nvim-jdtls`
local config = {
  cmd = {
    'java',
    '-javaagent:' .. lombok_path,
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '-jar', vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', mason_path .. '/config_linux', -- Adjust `config_linux` for your OS
    '-data', workspace_path .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
  },
  root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }),
  settings = {
    java = {
      format = {
        enabled = true,
      },
      saveActions = {
        organizeImports = true,
      },
    },
  },
  init_options = {
    bundles = {
      vim.fn.glob(home .. '/.config/nvim/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'),
      unpack(vim.fn.glob(home .. '/.config/nvim/vscode-java-test/server/*.jar', 1, 1)),
    },
  },
}

-- Start or attach `nvim-jdtls`
jdtls.start_or_attach(config)

