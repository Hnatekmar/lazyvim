return {
  "saghen/blink.cmp",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = {
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<A-y>"] = {
        function(cmp)
          cmp.show({ providers = { "minuet" } })
        end,
      },
    },
    cmdline = {
      enabled = false,
    },
    completion = {
      menu = { auto_show = false },
      trigger = {
        prefetch_on_insert = false,
        show_on_keyword = false,
        show_on_trigger_character = false,
        show_on_insert = false,
      },
    },
    sources = {
      default = { "lsp" },
      -- Minuet available via manual <A-y> trigger only (dropdown),
      -- auto-completion handled by virtualtext ghost text.
      providers = {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          async = true,
          timeout_ms = 8000,
          score_offset = 50,
        },
      },
    },
  },
}
