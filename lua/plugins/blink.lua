return {
  "saghen/blink.cmp",
  dependencies = { "Kaiser-Yang/blink-cmp-avante", "rafamadriz/friendly-snippets" },
  opts = {
    keymap = {
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
    },
    sources = {
      default = { "avante", "lsp", "path", "buffer", "minuet" },
      providers = {
        avante = { module = "blink-cmp-avante", name = "Avante" },
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
