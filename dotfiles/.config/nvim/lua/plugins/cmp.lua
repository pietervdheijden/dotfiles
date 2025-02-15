return {
  {
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
  {
    "onsails/lspkind.nvim",
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')

      local function has_words_before()
        if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' then
          return false
        end
        local line_nr, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, true)[1]
        return col ~= 0 and line:sub(col, col):match('%s') == nil
      end

      local function tab_complete(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete({ reason = cmp.ContextReason.Auto })
        else
          fallback()
        end
      end

      local function s_tab_complete(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end

      cmp.setup {
        completion = {
          completeopt = 'menu,menuone,noinsert',
          autocomplete = false,
        },
        mapping = {
          ['<Tab>'] = cmp.mapping(tab_complete, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(s_tab_complete, { 'i', 's' }),
          ['<Esc>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-D>'] = cmp.mapping.scroll_docs(4),
          ['<C-U>'] = cmp.mapping.scroll_docs(-4),
          ['<C-space>'] = cmp.mapping.complete(),
        },
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol",
            max_width = 50,
            symbol_map = { Copilot = "" },
            before = function(entry, vim_item)
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
                copilot = "[Copilot]",
              })[entry.source.name]
              return vim_item
            end,
          })
        },
        sources = {
          { name = 'copilot' },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
        },
      }
    end
  }
}
