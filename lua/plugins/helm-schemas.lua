return {
  -- Helm template schemas and Kubernetes resource stubs
  -- Provides:
  --   <leader>hs - Template picker (insert K8s resource stubs)
  --   <leader>hC - Live cluster CRD sync (pulls schemas from active kubectl context)
  --   <leader>hS - Sync SchemaStore templates
  --   <leader>hk - Core K8s types
  {
    "gijsentius/helm-schemas.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {},
  },
}
