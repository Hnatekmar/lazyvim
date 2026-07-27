return {
  "nvim-neorg/neorg",
  lazy = false,
  version = "*",
  build = ":Neorg sync-parsers",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "vhyrro/luarocks.nvim",
      priority = 1000,
      config = true,
    },
  },
  config = true,
}
