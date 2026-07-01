return {
  "neovim/nvim-lspconfig",
  opts = {
    -- make sure mason installs the server
    servers = {
      yamlls = {
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            -- Enable the built-in schema store for non-K8s YAML files
            schemaStore = {
              enable = true,
            },
            schemas = {
              -- K8s: only match files with a resource type suffix (e.g. app.deployment.yaml)
              -- instead of greedily matching all *.yaml files
              [require("kubernetes").yamlls_schema()] = require("kubernetes").yamlls_filetypes(),
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
      },
    },
  },
}
