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
        context_window = 32000,
        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            end_point = "https://llm.hnatekmar.dev/qwen-next-instruct/v1/completions",
            model = "qwen-next-instruct",
            name = "vllm",
            optional = {
              max_tokens = 256,
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
