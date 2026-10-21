-- Kubernetes schema wiring for yamlls.
--
-- kubernetes.nvim's yamlls_filetypes() runs `kubectl api-resources` through a
-- *blocking* job every time it is called. In a headless dev env kubectl hits
-- the kubeconfig's exec plugin (kubelogin), which starts the authcode-browser
-- flow and waits for a browser that does not exist -> nvim never finishes
-- reading the buffer and looks frozen until you press Ctrl+C.
--
-- So: never call it while starting up. Read a cached glob list, refresh it in
-- the background (bounded by a timeout), and re-attach yamlls once it lands.

local function refresh_k8s_filetypes(schemas, schema_url)
  local dir = vim.fn.stdpath("data") .. "/kubernetes.nvim"
  local cache = dir .. "/yamlls_filetypes.json"

  local function read_cache()
    local fd = io.open(cache, "r")
    if not fd then
      return nil
    end
    local body = fd:read("*a")
    fd:close()
    local ok, fts = pcall(vim.json.decode, body)
    if ok and type(fts) == "table" and #fts > 0 then
      return fts
    end
    return nil
  end

  local cached = read_cache()
  if cached then
    schemas[schema_url] = cached
  end

  -- Startup never waits on the cluster: bounded, off the main loop.
  vim.system({ "kubectl", "api-resources", "--no-headers" }, { text = true, timeout = 5000 }, function(res)
    if res.code ~= 0 or not res.stdout or res.stdout == "" then
      return
    end
    local fts = {}
    for _, line in ipairs(vim.split(res.stdout, "\n", { plain = true })) do
      local kind = line:gsub(".* (%w+)$", "%1"):lower()
      if kind ~= "" and kind ~= line then
        fts[#fts + 1] = "*." .. kind .. ".yml"
        fts[#fts + 1] = "*." .. kind .. ".yaml"
      end
    end
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({ vim.json.encode(fts) }, cache)
    schemas[schema_url] = fts
    -- Re-attach yamlls so it picks up the globs now instead of next start.
    vim.schedule(function()
      for _, client in ipairs(vim.lsp.get_clients({ name = "yamlls" })) do
        pcall(function()
          client:stop()
        end)
      end
      if vim.bo.filetype == "yaml" and not vim.bo.modified then
        pcall(vim.cmd, "silent! edit")
      end
    end)
  end)
end

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Safely require kubernetes; skip k8s schemas if not available
    -- (e.g. no cluster running, kubectl not installed)
    local k8s_ok, k8s = pcall(require, "kubernetes")
    local k8s_schema = ""
    if k8s_ok then
      local schema_ok, schema = pcall(k8s.yamlls_schema)
      if schema_ok then
        k8s_schema = schema
      end
    end

    local schemas = {
      ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
      ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
      ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
      ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
      ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
      ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
      ["https://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
    }

    if k8s_schema ~= "" then
      schemas[k8s_schema] = {}
      refresh_k8s_filetypes(schemas, k8s_schema)
    end

    opts.servers = opts.servers or {}
    opts.servers.yamlls = {
      settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
          schemaStore = {
            enable = true,
          },
          schemas = schemas,
        },
      },
    }

    return opts
  end,
}
