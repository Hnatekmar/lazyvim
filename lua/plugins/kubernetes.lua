return {
  "diogo464/kubernetes.nvim",
  opts = {
    schema_strict = true,
    -- true:  generate the schema every time the plugin starts
    -- false: only generate the schema if the files don't already exists. run `:KubernetesGenerateSchema` manually to generate the schema if needed.
    schema_generate_always = true,
  },
}
