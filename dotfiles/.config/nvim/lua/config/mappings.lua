local This = {}

local map = vim.keymap.set

-- Helper function for creating keymaps
local function noremap(mode, rhs, lhs, desc, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, desc = desc }
  vim.keymap.set(mode, rhs, lhs, opts)
end
local function nnoremap(rhs, lhs, desc, bufnr)
  noremap('n', rhs, lhs, desc, bufnr)
end
local function vnoremap(rhs, lhs, desc, bufnr)
  noremap('v', rhs, lhs, desc, bufnr)
end
local function inoremap(rhs, lhs, desc, bufnr)
  noremap('i', rhs, lhs, desc, bufnr)
end


function This.setup()
  -- telescope
  local telescope = require('telescope.builtin')
  nnoremap('<leader>ff', telescope.find_files, "TS: Find files")
  nnoremap('<leader>fg', telescope.live_grep, "TS: Live grep")
  nnoremap('<leader>fb', telescope.buffers, "TS: Buffers")
  nnoremap('<leader>fh', telescope.help_tags, "TS: Help tags")
  nnoremap('<leader>fr', telescope.resume, "TS: Resume")
  nnoremap('<leader>fw', telescope.grep_string, "TS: Search word under cursor")
  nnoremap('<leader>fc', telescope.current_buffer_fuzzy_find, "TS: Search in current buffer")
  nnoremap('<leader>fo', telescope.oldfiles, "TS: Recently opened files")
  nnoremap('<leader>fk', telescope.keymaps, "TS: Keymaps")
  nnoremap('<leader>fs', telescope.lsp_document_symbols, "TS: LSP symbols")

  -- bufferline
  nnoremap('<leader>bd', ':bdelete<CR>', 'Close buffer')
  nnoremap('<leader>bD', ':bdelete!<CR>', 'Force close buffer')
  nnoremap('<leader>bn', ':bnext<CR>', 'Next buffer')
  nnoremap('<leader>bp', ':bprevious<CR>', 'Previous buffer')
  nnoremap('<leader>bdc', function() _G.delete_current_buffer() end, 'Delete current buffer (smart)')
  nnoremap('<leader>bdo', function() _G.delete_other_buffers() end, 'Delete other buffers')
  nnoremap('<leader>bdl', function() _G.delete_left_buffers() end, 'Delete buffers to the left')
  nnoremap('<leader>bdr', function() _G.delete_right_buffers() end, 'Delete buffers to the right')

  -- vim-tmux-navigator
  nnoremap('<C-h>', '<cmd>TmuxNavigateLeft<cr>', 'Navigate left (tmux aware)')
  nnoremap('<C-j>', '<cmd>TmuxNavigateDown<cr>', 'Navigate down (tmux aware)')
  nnoremap('<C-k>', '<cmd>TmuxNavigateUp<cr>', 'Navigate up (tmux aware)')
  nnoremap('<C-l>', '<cmd>TmuxNavigateRight<cr>', 'Navigate right (tmux aware)')
  nnoremap('<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', 'Navigate to previous (tmux aware)')

  -- nvim-tree
  nnoremap('<leader>fn', function()
    require('nvim-tree.api').tree.toggle({ find_file = true })
  end, 'Toggle file tree and find file')
  nnoremap('<leader>e', function()
    local nvim_tree_focused = vim.api.nvim_get_current_win() == require('nvim-tree.view').get_winnr()
    if nvim_tree_focused then
      vim.cmd.wincmd('p')
    else
      require('nvim-tree.api').tree.focus()
    end
  end, 'Toggle focus between editor and file tree')

  -- git
  nnoremap('<leader>gs', telescope.git_status, 'Git status')
  nnoremap('<leader>gc', telescope.git_commits, 'Git commits')
  nnoremap('<leader>gb', telescope.git_branches, 'Git branches')
  nnoremap('<leader>gd', function() require('gitsigns').diffthis() end, 'Git diff')
  nnoremap('<leader>lg', '<cmd>LazyGit<cr>', 'Open LazyGit')

  -- quick actions
  nnoremap('<leader>w', ':w<CR>', 'Save file')
  nnoremap('<leader>x', ':x<CR>', 'Save and close')
  inoremap('<C-s>', '<Esc>:w<CR>a', 'Save file (insert mode)')
  nnoremap('<Esc><Esc>', ':nohlsearch<CR>', 'Clear search highlight')
  nnoremap('<leader>qa', ':qa<CR>', 'Quit all')
  nnoremap('<leader>qf', ':copen<CR>', "Open Quickfix List")

  -- terminal
  nnoremap('<leader>tt', ':terminal<CR>', 'Open terminal')
  nnoremap('<leader>tf', function()
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
  end, 'Floating terminal')

  -- which-key
  nnoremap('<leader>?', function()
    require("which-key").show({ global = false })
  end, "Buffer Local Keymaps (which-key)")

  -- LazyVim
  nnoremap('<leader>lv', ':Lazy<CR>', 'Open LazyVim')
end

function This.setup_lsp(bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- LSP
  nnoremap('gD', vim.lsp.buf.declaration, 'LSP: Go to declaration', bufnr)
  nnoremap('gd', vim.lsp.buf.definition, 'LSP: Go to definition', bufnr)
  nnoremap('gi', vim.lsp.buf.implementation, 'LSP: Go to implementation', bufnr)
  nnoremap('K', vim.lsp.buf.hover, 'LSP: Hover text', bufnr)
  nnoremap('<C-k>', vim.lsp.buf.signature_help, 'LSP: Show signature', bufnr)
  nnoremap('<leader>wa', vim.lsp.buf.add_workspace_folder, 'LSP: Add workspace folder', bufnr)
  nnoremap('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'LSP: Remove workspace folder', bufnr)
  nnoremap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    'LSP: List workspace folders', bufnr)
  nnoremap('<leader>D', vim.lsp.buf.type_definition, 'LSP: Go to type definition', bufnr)
  nnoremap('<leader>rn', vim.lsp.buf.rename, 'LSP: Rename', bufnr)
  nnoremap('gr', vim.lsp.buf.references, 'LSP: Find references', bufnr)
  nnoremap('<leader>ca', vim.lsp.buf.code_action, "LSP: Code actions", bufnr)
  vnoremap('<leader>ca', function() vim.lsp.buf.range_code_action() end, "LSP code actions", bufnr)
  nnoremap('<leader>e', function() vim.diagnostic.open_float(nil, { focusable = false }) end,
    'LSP: Open diagnostic float', bufnr)
  nnoremap('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'LSP: Go to previous diagnostic', bufnr)
  nnoremap(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'LSP: Go to next diagnostic', bufnr)
  nnoremap('<leader>q', function() vim.diagnostic.setqflist() end, 'LSP: Set quickfix for diagnostic', bufnr)
  nnoremap('<leader>f', function() vim.lsp.buf.format({ async = true }) end, 'LSP: Format file', bufnr)
  nnoremap('<leader>lr', ':LspRestart<CR>', 'LSP: Restart', bufnr)
  nnoremap('<leader>li', ':LspInfo<CR>', 'LSP: Info', bufnr)
  nnoremap('gl', function() vim.diagnostic.open_float(nil, { focusable = false }) end, 'LSP: Show line diagnostics',
    bufnr)

  -- DAP
  local dap = require('dap')
  nnoremap("<leader>bb", dap.toggle_breakpoint, "DAP: Set breakpoint", bufnr)
  nnoremap("<leader>bc", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
    "DAP: Set conditional breakpoint", bufnr)
  nnoremap("<leader>bl", function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
    "DAP: Set log point", bufnr)
  nnoremap('<leader>br', dap.clear_breakpoints, "DAP: Clear breakpoints", bufnr)
  nnoremap('<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>', "DAP: List breakpoints", bufnr)

  nnoremap("<leader>dc", dap.continue, "DAP: Continue", bufnr)
  nnoremap("<leader>dj", dap.step_over, "DAP: Step over", bufnr)
  nnoremap("<leader>dk", dap.step_into, "DAP: Step into", bufnr)
  nnoremap("<leader>do", dap.step_out, "DAP: Step out", bufnr)
  nnoremap('<leader>dd', dap.disconnect, "DAP: Disconnect", bufnr)
  nnoremap('<leader>dt', dap.terminate, "DAP: Terminate", bufnr)
  nnoremap("<leader>dr", dap.repl.toggle, "DAP: Open REPL", bufnr)
  nnoremap("<leader>dl", dap.run_last, "DAP: Run last", bufnr)
  nnoremap('<leader>di', function() require "dap.ui.widgets".hover() end, "DAP: Variables", bufnr)
  nnoremap('<leader>d?', function()
    local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
  end, "DAP: Scopes", bufnr)
  nnoremap('<leader>df', '<cmd>Telescope dap frames<cr>', "DAP: List frames", bufnr)
  nnoremap('<leader>dh', '<cmd>Telescope dap commands<cr>', "DAP: List commands", bufnr)
end

function This.setup_nvimtree(bufnr)
  local api = require('nvim-tree.api')

  nnoremap('<CR>', api.node.open.edit, 'nvim-tree: Open', bufnr)
  nnoremap('J', api.node.open.horizontal, 'nvim-tree: Open in horizontal split', bufnr)
  nnoremap('L', api.node.open.vertical, 'nvim-tree: Open in vertical split', bufnr)
  nnoremap('K', api.node.show_info_popup, 'nvim-tree: Info', bufnr)
  nnoremap('R', api.tree.reload, 'nvim-tree: Refresh', bufnr)
  nnoremap('a', api.fs.create, 'nvim-tree: Create', bufnr)
  nnoremap('d', api.fs.remove, 'nvim-tree: Delete', bufnr)
  nnoremap('g?', api.tree.toggle_help, 'nvim-tree: Help', bufnr)
  nnoremap('p', api.fs.paste, 'nvim-tree: Paste', bufnr)
  nnoremap('r', api.fs.rename, 'nvim-tree: Rename', bufnr)
  nnoremap('x', api.fs.cut, 'nvim-tree: Cut', bufnr)
  nnoremap('c', api.fs.copy.node, 'nvim-tree: Copy', bufnr)
  nnoremap('<2-LeftMouse>', api.node.open.edit, 'nvim-tree: Open with mouse double-click', bufnr)
end

function This.setup_gitsigns(bufnr)
  local gitsigns = require('gitsigns')

  -- Navigation
  nnoremap(']c', function()
    if vim.wo.diff then
      vim.cmd.normal({ ']c', bang = true })
    else
      gitsigns.nav_hunk('next')
    end
  end, 'Next git hunk', bufnr)

  nnoremap('[c', function()
    if vim.wo.diff then
      vim.cmd.normal({ '[c', bang = true })
    else
      gitsigns.nav_hunk('prev')
    end
  end, 'Previous git hunk', bufnr)

  -- Actions
  nnoremap('<leader>hs', gitsigns.stage_hunk, 'Git stage hunk', bufnr)
  nnoremap('<leader>hr', gitsigns.reset_hunk, 'Git reset hunk', bufnr)
  vnoremap('<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, 'Git stage hunk',
    bufnr)
  vnoremap('<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, 'Git reset hunk',
    bufnr)
  nnoremap('<leader>hS', gitsigns.stage_buffer, 'Git stage buffer', bufnr)
  nnoremap('<leader>hu', gitsigns.undo_stage_hunk, 'Git undo stage hunk', bufnr)
  nnoremap('<leader>hR', gitsigns.reset_buffer, 'Git reset buffer', bufnr)
  nnoremap('<leader>hp', gitsigns.preview_hunk, 'Git preview hunk', bufnr)
  nnoremap('<leader>hb', function() gitsigns.blame_line { full = true } end, 'Git blame line', bufnr)
  nnoremap('<leader>tb', gitsigns.toggle_current_line_blame, 'Git toggle current line blame', bufnr)
  nnoremap('<leader>hd', gitsigns.diffthis, 'Git diff', bufnr)
  nnoremap('<leader>hD', function() gitsigns.diffthis('~') end, 'Git diff ~', bufnr)
  nnoremap('<leader>td', gitsigns.toggle_deleted, 'Git toggle deleted', bufnr)

  -- Text object
  noremap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select git hunk', bufnr)
end

return This
