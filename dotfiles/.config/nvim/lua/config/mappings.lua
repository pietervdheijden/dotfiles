local This = {}

local map = vim.keymap.set

function This.setup()
  -- Telescope
  local telescope = require('telescope.builtin')
  map('n', '<leader>ff', telescope.find_files, { desc = "TS: Find files" })
  map('n', '<leader>fg', telescope.live_grep, { desc = "TS: Live grep" })
  map('n', '<leader>fb', telescope.buffers, { desc = "TS: Buffers" })
  map('n', '<leader>fh', telescope.help_tags, { desc = "TS: Help tags" })
  map('n', '<leader>fr', telescope.resume, { desc = "TS: Resume" })

  -- LazyVim
  map('n', '<leader>lv', ':Lazy<CR>', { desc = 'Open LazyVim' })

  -- Other
  map('n', '<leader>qa', ':qa<CR>', { desc = 'Quit all' })
  map('n', '<leader>qf', ':copen<CR>', { desc = "Open Quickfix List" })
end

function This.setup_lsp(bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Define bufopts for buffer-local keymaps
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- Helper function for creating keymaps
  local function nnoremap(rhs, lhs, desc)
    -- bufopts = bufopts or {}
    -- bufopts.desc = desc
    local opts = vim.tbl_extend('force', bufopts, { desc = desc })
    vim.keymap.set("n", rhs, lhs, opts)
  end


  -- LSP
  -- Mappings.
  local function opts(desc)
    return { desc = 'LSP: ' .. desc, noremap = true, silent = true }
  end
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  nnoremap('gD', vim.lsp.buf.declaration, 'Go to declaration')
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts('Go to definition'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts('Go to implementation'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts('Hover text'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts('Show signature'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
    opts('Add workspace folder'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
    opts('Remove workspace folder'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts('List workspace folders'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    opts('Go to type definition'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts('Rename'))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts('Find refenerences'))
  nnoremap('<space>ca', vim.lsp.buf.code_action, "Code actions")
  vim.keymap.set('v', "<space>ca", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
    { noremap = true, silent = true, buffer = bufnr, desc = "Code actions" })
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    opts("Go to previous diagnostic"))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts("Go to next diagnostic"))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>',
    opts("Set loclist for diagnostic"))
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>',
    opts('Format file'))

  -- Reload diagnostics
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rd', '<cmd>lua vim.diagnostic.reset() vim.diagnostic.show()<CR>', opts)

  -- DAP
  nnoremap("<space>bb", "<cmd>lua require('dap').toggle_breakpoint()<cr>", "Set breakpoint")
  nnoremap("<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
    "Set conditional breakpoint")
  nnoremap("<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>",
    "Set log point")
  nnoremap('<leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>", "Clear breakpoints")
  nnoremap('<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>', "List breakpoints")

  nnoremap("<leader>dc", "<cmd>lua require'dap'.continue()<cr>", "Continue")
  nnoremap("<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", "Step over")
  nnoremap("<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", "Step into")
  nnoremap("<leader>do", "<cmd>lua require'dap'.step_out()<cr>", "Step out")
  nnoremap('<leader>dd', "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect")
  nnoremap('<leader>dt', "<cmd>lua require'dap'.terminate()<cr>", "Terminate")
  nnoremap("<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", "Open REPL")
  nnoremap("<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", "Run last")
  nnoremap('<leader>di', function() require "dap.ui.widgets".hover() end, "Variables")
  nnoremap('<leader>d?', function()
    local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
  end, "Scopes")
  nnoremap('<leader>df', '<cmd>Telescope dap frames<cr>', "List frames")
  nnoremap('<leader>dh', '<cmd>Telescope dap commands<cr>', "List commands")
end

return This
