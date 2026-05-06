return {
  "rainbowhxch/beacon.nvim",
  event = "VeryLazy",
  opts = {
    enable = true,
    size = 60,
    fade = true,
    minimal_jump = 10,
    show_jumps = true,
    focus_gained = false,
    shrink = true,
    timeout = 1500,
    ignore_buffers = {},
    ignore_filetypes = {
      "qf",
      "NvimTree",
      "fugitive",
      "TelescopePrompt",
      "TelescopeResult",
    },
  },
}
