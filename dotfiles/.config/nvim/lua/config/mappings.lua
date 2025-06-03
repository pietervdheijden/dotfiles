local This = {}

local map = vim.keymap.set

function This.setup()
  -- telescope
  local telescope = require('telescope.builtin')
  map('n', '<leader>ff', telescope.find_files, { desc = "TS: Find files" })
  map('n', '<leader>fg', telescope.live_grep, { desc = "TS: Live grep" })
  map('n', '<leader>fb', telescope.buffers, { desc = "TS: Buffers" })
  map('n', '<leader>fh', telescope.help_tags, { desc = "TS: Help tags" })
  map('n', '<leader>fr', telescope.resume, { desc = "TS: Resume" })
  map('n', '<leader>fw', telescope.grep_string, { desc = "TS: Search word under cursor" })
  map('n', '<leader>fc', telescope.current_buffer_fuzzy_find, { desc = "TS: Search in current buffer" })
  map('n', '<leader>fo', telescope.oldfiles, { desc = "TS: Recently opened files" })
  map('n', '<leader>fk', telescope.keymaps, { desc = "TS: Keymaps" })
  map('n', '<leader>fs', telescope.lsp_document_symbols, { desc = "TS: LSP symbols" })

  -- bufferline
  map('n', '<leader>bd', ':bdelete<CR>', { desc = 'Close buffer' })
  map('n', '<leader>bD', ':bdelete!<CR>', { desc = 'Force close buffer' })
  map('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
  map('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
  map('n', '<leader>bdc', function() _G.delete_current_buffer() end, { desc = 'Delete current buffer (smart)' })
  map('n', '<leader>bdo', function() _G.delete_other_buffers() end, { desc = 'Delete other buffers' })
  map('n', '<leader>bdl', function() _G.delete_left_buffers() end, { desc = 'Delete buffers to the left' })
  map('n', '<leader>bdr', function() _G.delete_right_buffers() end, { desc = 'Delete buffers to the right' })

  -- vim-tmux-navigator
  map('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { desc = 'Navigate left (tmux aware)' })
  map('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { desc = 'Navigate down (tmux aware)' })
  map('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { desc = 'Navigate up (tmux aware)' })
  map('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { desc = 'Navigate right (tmux aware)' })
  map('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', { desc = 'Navigate to previous (tmux aware)' })

  -- nvim-tree
  map('n', '<leader>fn', function()
    require('nvim-tree.api').tree.toggle({ find_file = true })
  end, { desc = 'Toggle file tree and find file' })
  map('n', '<leader>e', function()
    local nvim_tree_focused = vim.api.nvim_get_current_win() == require('nvim-tree.view').get_winnr()
    if nvim_tree_focused then
      vim.cmd.wincmd('p')
    else
      require('nvim-tree.api').tree.focus()
    end
  end, { desc = 'Toggle focus between editor and file tree' })

  -- git
  map('n', '<leader>gs', telescope.git_status, { desc = 'Git status' })
  map('n', '<leader>gc', telescope.git_commits, { desc = 'Git commits' })
  map('n', '<leader>gb', telescope.git_branches, { desc = 'Git branches' })
  map('n', '<leader>gd', function() require('gitsigns').diffthis() end, { desc = 'Git diff' })
  map('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'Open LazyGit' })

  -- quick actions
  map('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
  map('n', '<leader>x', ':x<CR>', { desc = 'Save and close' })
  map('i', '<C-s>', '<Esc>:w<CR>a', { desc = 'Save file (insert mode)' })
  map('n', '<Esc><Esc>', ':nohlsearch<CR>', { desc = 'Clear search highlight' })
  map('n', '<leader>qa', ':qa<CR>', { desc = 'Quit all' })
  map('n', '<leader>qf', ':copen<CR>', { desc = "Open Quickfix List" })

  -- terminal
  map('n', '<leader>tt', ':terminal<CR>', { desc = 'Open terminal' })
  map('n', '<leader>tf', function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
      row = math.floor(vim.o.lines * 0.1),
      col = math.floor(vim.o.columns * 0.1),
      border = 'rounded'
    })
    vim.cmd('terminal')
  end, { desc = 'Floating terminal' })

  -- which-key
  map('n', '<leader>?', function()
    require("which-key").show({ global = false })
  end, { desc = "Buffer Local Keymaps (which-key)" })

  -- LazyVim
  map('n', '<leader>lv', ':Lazy<CR>', { desc = 'Open LazyVim' })
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
  nnoremap('<leader>lr', ':LspRestart<CR>', 'LSP: Restart')
  nnoremap('<leader>li', ':LspInfo<CR>', 'LSP: Info')
  nnoremap('gl', function() vim.diagnostic.open_float(nil, { focusable = false }) end, 'LSP: Show line diagnostics')

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
