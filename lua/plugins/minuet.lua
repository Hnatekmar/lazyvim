return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "openai_fim_compatible",
        request_timeout = 2.5,
        n_completions = 4,
        throttle = 1500, -- Increase to reduce costs and avoid rate limits
        debounce = 600, -- Increase to reduce costs and avoid rate limits
        context_window = 16000,
        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            end_point = "https://llm.hnatekmar.dev/qwen3-30b-instruct/v1/completions",
            model = "qwen3-30b-instruct",
            name = "vllm",
            optional = {
              max_tokens = 4096,
              provider = {
                -- Prioritize throughput for faster completion
                sort = "throughput",
              },
            },
            template = {
              prompt = function(context_before_cursor, context_after_cursor, _)
                return "<|fim_prefix|>"
                  .. context_before_cursor
                  .. "<|fim_suffix|>"
                  .. context_after_cursor
                  .. "<|fim_middle|>"
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
