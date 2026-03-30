return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "openai_fim_compatible",
        request_timeout = 5,
        n_completions = 3,
        throttle = 1000, -- Increase to reduce costs and avoid rate limits
        debounce = 50, -- Increase to reduce costs and avoid rate limits
        context_window = 64000,
        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            end_point = "https://fast.hnatekmar.dev/v1/completions",
            model = "Qwen/Qwen3-Coder-Next-FP8",
            name = "vllm",
            optional = {
              max_tokens = 128,
              provider = {
                -- Prioritize throughput for faster completion
                sort = "throughput",
              },
            },
            template = {
              prompt = function(context_before_cursor, context_after_cursor, _)
                local parts = {}

                table.insert(parts, "<|fim_prefix|>")
                table.insert(parts, context_before_cursor)
                table.insert(parts, "<|fim_suffix|>")
                table.insert(parts, context_after_cursor)
                table.insert(parts, "<|fim_middle|>")

                return table.concat(parts, "") -- No extra spaces, tokens handle separation
              end,
              suffix = false,
            },
          },
        },
      })
    end,
  },
  { "nvim-lua/plenary.nvim" },
}
