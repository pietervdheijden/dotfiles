return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewFileHistory",
    "DiffviewRefresh",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = function()
    local actions = require("diffview.actions")
    -- Open the entry under the cursor and move focus into the diff window,
    -- so a single key takes you from the file panel into yankable buffer text.
    local function select_and_focus()
      actions.select_entry()
      vim.cmd("wincmd l")
    end
    return {
      enhanced_diff_hl = true,
      keymaps = {
        -- Live-preview the diff while scrolling the entry list (focus stays
        -- in the panel), and jump into the diff only on <cr>/o.
        file_panel = {
          { "n", "j",    actions.select_next_entry, { desc = "Next file (preview diff)" } },
          { "n", "k",    actions.select_prev_entry, { desc = "Prev file (preview diff)" } },
          { "n", "<cr>", select_and_focus,          { desc = "Open diff and focus it" } },
          { "n", "o",    select_and_focus,          { desc = "Open diff and focus it" } },
        },
        file_history_panel = {
          { "n", "j",    actions.select_next_entry, { desc = "Next commit (preview diff)" } },
          { "n", "k",    actions.select_prev_entry, { desc = "Prev commit (preview diff)" } },
          { "n", "<cr>", select_and_focus,          { desc = "Open diff and focus it" } },
          { "n", "o",    select_and_focus,          { desc = "Open diff and focus it" } },
        },
      },
    }
  end,
}
