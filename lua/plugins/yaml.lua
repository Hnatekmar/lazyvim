return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Safely require kubernetes; skip k8s schemas if not available
    -- (e.g. no cluster running, kubectl not installed)
    local k8s_ok, k8s = pcall(require, "kubernetes")
    local k8s_schema = ""
    local k8s_filetypes = {}
    if k8s_ok then
      local schema_ok, schema = pcall(k8s.yamlls_schema)
      local ft_ok, filetypes = pcall(k8s.yamlls_filetypes)
      if schema_ok then k8s_schema = schema end
      if ft_ok then k8s_filetypes = filetypes end
    end

    opts.servers = opts.servers or {}
    opts.servers.yamlls = {
      settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
          schemaStore = {
            enable = true,
          },
          schemas = {
            [k8s_schema] = k8s_filetypes,
            ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
            ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
            ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
            ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
            ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
            ["https://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
          },
        },
      },
    }

    return opts
  end,
}
