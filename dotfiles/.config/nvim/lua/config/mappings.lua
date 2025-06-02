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
  nnoremap('gD', vim.lsp.buf.declaration, 'LSP: Go to declaration')
  nnoremap('gd', vim.lsp.buf.definition, 'LSP: Go to definition')
  nnoremap('gi', vim.lsp.buf.implementation, 'LSP: Go to implementation')
  nnoremap('K', vim.lsp.buf.hover, 'LSP: Hover text')
  nnoremap('<C-k>', vim.lsp.buf.signature_help, 'LSP: Show signature')
  nnoremap('<leader>wa', vim.lsp.buf.add_workspace_folder, 'LSP: Add workspace folder')
  nnoremap('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'LSP: Remove workspace folder')
  nnoremap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    'LSP: List workspace folders')
  nnoremap('<leader>D', vim.lsp.buf.type_definition, 'LSP: Go to type definition')
  nnoremap('<leader>rn', vim.lsp.buf.rename, 'LSP: Rename')
  nnoremap('gr', vim.lsp.buf.references, 'LSP: Find references')
  nnoremap('<leader>ca', vim.lsp.buf.code_action, "LSP: Code actions")
  vim.keymap.set('v', "<leader>ca", function() vim.lsp.buf.range_code_action() end,
    { noremap = true, silent = true, buffer = bufnr, desc = "LSP: Code actions" })
  nnoremap('<leader>e', function() vim.diagnostic.open_float(nil, { focusable = false }) end,
    'LSP: Open diagnostic float')
  nnoremap('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'LSP: Go to previous diagnostic')
  nnoremap(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'LSP: Go to next diagnostic')
  nnoremap('<leader>q', function() vim.diagnostic.setqflist() end, 'LSP: Set quickfix for diagnostic')
  nnoremap('<leader>f', function() vim.lsp.buf.format({ async = true }) end, 'LSP: Format file')

  -- Reload diagnostics
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rd', '<cmd>lua vim.diagnostic.reset() vim.diagnostic.show()<CR>', opts)

  -- DAP
  local dap = require('dap')
  nnoremap("<leader>bb", dap.toggle_breakpoint, "DAP: Set breakpoint")
  nnoremap("<leader>bc", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
    "DAP: Set conditional breakpoint")
  nnoremap("<leader>bl", function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
    "DAP: Set log point")
  nnoremap('<leader>br', dap.clear_breakpoints, "DAP: Clear breakpoints")
  nnoremap('<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>', "DAP: List breakpoints")

  nnoremap("<leader>dc", dap.continue, "DAP: Continue")
  nnoremap("<leader>dj", dap.step_over, "DAP: Step over")
  nnoremap("<leader>dk", dap.step_into, "DAP: Step into")
  nnoremap("<leader>do", dap.step_out, "DAP: Step out")
  nnoremap('<leader>dd', dap.disconnect, "DAP: Disconnect")
  nnoremap('<leader>dt', dap.terminate, "DAP: Terminate")
  nnoremap("<leader>dr", dap.repl.toggle, "DAP: Open REPL")
  nnoremap("<leader>dl", dap.run_last, "DAP: Run last")
  nnoremap('<leader>di', function() require "dap.ui.widgets".hover() end, "DAP: Variables")
  nnoremap('<leader>d?', function()
    local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
  end, "DAP: Scopes")
  nnoremap('<leader>df', '<cmd>Telescope dap frames<cr>', "DAP: List frames")
  nnoremap('<leader>dh', '<cmd>Telescope dap commands<cr>', "DAP: List commands")
end

return This
