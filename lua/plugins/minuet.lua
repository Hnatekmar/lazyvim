return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "openai_compatible",
        request_timeout = 10,
        n_completions = 2,
        throttle = 1000,
        debounce = 50,
        context_window = 32000,
        provider_options = {
          openai_compatible = {
            api_key = "TERM",
            -- Point to the standard completions route your gateway expects
            end_point = "http://172.16.100.160:9090/deepseek/v1/chat/completions",
            model = "deepseek-ai/DeepSeek-V4-Flash",
            name = "vllm",
            stream = true,
          },
        },
      })
    end,
  },
  { "nvim-lua/plenary.nvim" },
}
