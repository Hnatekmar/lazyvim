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
    completion = {
      trigger = { prefetch_on_insert = false },
    },
    sources = {
      default = { "lsp", "path", "buffer" },
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
