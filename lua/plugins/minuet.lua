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
        add_single_line_entry = false,
        provider_options = {
          openai_compatible = {
            api_key = "TERM",
            -- Point to the standard completions route your gateway expects
            end_point = "https://proxy.personal-hermes.hnatekmar.dev/v1/chat/completions",
            model = "qwen36-coding",
            name = "vllm",
            stream = true,
            optional = {
              max_tokens = 256,
            },
          },
        },
      })
    end,
  },
  { "nvim-lua/plenary.nvim" },
}
