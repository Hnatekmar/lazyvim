return {
  -- Helm template schemas and Kubernetes resource stubs
  -- Provides:
  --   <leader>hs - Template picker (insert K8s resource stubs)
  --   <leader>hc - Live cluster CRD sync (pulls schemas from active kubectl context)
  --   <leader>hC - Add CRD from file or URL
  --   <leader>hS - Sync SchemaStore templates
  --   <leader>hk - Core K8s types
  --   <leader>hd - Sync datreeio CRD schemas
  --   <leader>hx - Clear schemas
  {
    "gijsentius/helm-schemas.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {},
  },
}
