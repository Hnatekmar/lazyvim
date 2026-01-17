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
    sources = {
      default = { "lsp", "path", "buffer" },
      providers = {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          async = true,
          timeout_ms = 3000,
          score_ffset = 50,
        },
      },
      completion = { trigger = { prefetch_on_insert = false } },
    },
  },
}
