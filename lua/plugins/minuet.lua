-- Drop-in replacement for the minuet block in your dots repo.
-- Requires repo_context.lua on 'runtimepath' (e.g. ~/.config/nvim/lua/repo_context.lua).
local M = {}

function M.config()
  local rc = require("repo_context")

  -- Refresh on BufEnter / BufWritePost / LspAttach / InsertLeave, debounced.
  -- max_chars is the whole budget for injected cross-file context. 2400 chars
  -- is ~600 tokens: the measured sweet spot. Wider windows raise the rate of
  -- the right callee by ~2 points and double the degenerate-output rate.
  rc.setup({
    enabled = true,
    max_chars = 2400,
    max_files = 3,
    debounce_ms = 1500,
  })

  require("minuet").setup({
    provider = "openai_fim_compatible",
    request_timeout = 10,
    n_completions = 2,
    throttle = 1000,
    debounce = 50,
    context_window = 32000,
    add_single_line_entry = false,
    virtualtext = {
      auto_trigger_ft = { "*" },
      show_on_completion_menu = false,
      keymap = {
        accept = "<A-CR>",
        accept_line = "<A-a>",
        accept_n_lines = "<A-z>",
        next = "<A-n>",
        prev = "<A-p>",
        dismiss = "<A-e>",
      },
    },
    provider_options = {
      openai_fim_compatible = {
        api_key = function()
          return "noop"
        end,
        name = "mellum",
        end_point = "https://proxy.personal-hermes.hnatekmar.dev/v1/completions",
        model = "mellum-fim",
        stream = true,
        optional = {
          max_tokens = 64,
          stop = { "<|im_end|>", "<|endoftext|>", "\n" },
        },
        template = {
          prompt = function(context_before_cursor, context_after_cursor, _)
            -- Cross-file context goes FIRST and is byte-stable between
            -- keystrokes, so vLLM's prefix cache keeps hitting; anything
            -- volatile placed ahead of it would force a full re-prefill.
            return require("repo_context").get(0)
              .. "<fim_prefix>"
              .. context_before_cursor
              .. "<fim_suffix>"
              .. context_after_cursor
              .. "<fim_middle>"
          end,
          suffix = false,
        },
      },
    },
  })
end

return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      M.config()
    end,
  },
}
