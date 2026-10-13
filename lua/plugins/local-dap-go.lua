-- Local DAP-Go ergonomics: one-keypress test debugging.
-- Complements LazyVim's dap.core + lang.go extras (which register the Go
-- launch configs but ship no <leader>dgt/<leader>dgl mappings).
return {
  "leoluz/nvim-dap-go",
  keys = {
    {
      "<leader>dgt",
      function() require("dap-go").debug_test() end,
      desc = "Debug Go Test (nearest under cursor)",
      ft = "go",
    },
    {
      "<leader>dgl",
      function() require("dap-go").debug_last_test() end,
      desc = "Debug Go Test (last)",
      ft = "go",
    },
  },
}
