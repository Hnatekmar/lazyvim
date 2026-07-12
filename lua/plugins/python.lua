return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                -- "off" | "basic" | "standard" | "all"
                typeCheckingMode = "standard",
                diagnosticSeverityOverrides = {
                  reportUnknownVariableType = false,
                  reportUnknownMemberType = false,
                  reportUnknownArgumentType = false,
                  reportUnusedVariable = "information",
                },
              },
            },
          },
        },
      },
    },
  },
}
