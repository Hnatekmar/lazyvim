-- opencode.nvim — Neovim bridge to the opencode AI agent (opencode.ai).
--
-- Works against opencode's v2 server API rather than scraping the TUI:
--   - Prompts accept context placeholders (@this, @buffer, @diagnostics,
--     @marks, @quickfix, @visible) with completion/highlighting in the ask
--     input (via snacks.input, which LazyVim already enables).
--   - Edits made by opencode reload open buffers live; edit-permission
--     requests open a side-by-side :diffpatch review tab.
--   - Prompts/operators are range-aware and dot-repeatable.
--
-- Requirements: `opencode` >= 2.0 on PATH. OpenCode 2 keeps its server in a
-- background service that the TUI attaches to, so there is no `--port` flag:
-- the plugin discovers the service through
-- `~/.local/state/opencode/service.json`. Verify with `:checkhealth opencode`.
--
-- Keymaps (the `<leader>a` group, matching LazyVim's AI extras convention):
--   <leader>aa         Ask OpenCode (@this = selection or cursor position)
--   <leader>ac         Pick prompt/command/server (snacks.picker powered)
--   <leader>a,         Append @this to the TUI prompt without submitting
--   <leader>at         Toggle the opencode TUI (right-side snacks terminal)
--   <leader>af         Focus the opencode TUI
--   <C-.>              Alias of <leader>at (handy mid-typing)
--   go (operator)      Append motion/textobject range to the prompt
--   goo                Append current line
--   <a-o> (in picker)  Send selected file(s)/lines to opencode
--
-- Session actions (new/switch/interrupt/page) are TUI-side in OpenCode 2 and
-- have no server API, so they are handled by the TUI's own keys inside the
-- terminal rather than by maps here.
--
-- Unlike the plugin's recommended maps, nothing here shadows Neovim
-- defaults: <C-a>/<C-x> still increment/decrement. Only the rarely-used
-- `go` byte-offset jump is shadowed by the operator.

local opencode_cmd = "opencode"

---@type snacks.terminal.Opts
local snacks_terminal_opts = {
  win = {
    position = "right",
    enter = false,
  },
}

return {
  {
    "nickjvandyke/opencode.nvim",
    -- v2 support is not in a release yet: the newest tag (v1.0.2) speaks the
    -- v1 API, discovers servers by scanning for `opencode ... --port`
    -- processes and probes /global/health, none of which exist in OpenCode 2.
    -- Track main until a v2-capable release is tagged, then go back to
    -- `version = "*"` and drop the branch.
    branch = "main",
    init = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          -- Open the TUI as a toggleable snacks terminal instead of a
          -- plain term:// split.
          start = function()
            require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
          end,
        },
      }
    end,
    keys = {
      { "<leader>aa", function()
        require("opencode").ask("@this: ")
      end, mode = { "n", "x" }, desc = "Ask OpenCode (@this)" },
      { "<leader>ac", function()
        require("opencode").select()
      end, mode = { "n", "x" }, desc = "OpenCode prompts/commands" },
      { "<leader>a,", function()
        require("opencode").prompt("@this ")
      end, mode = { "n", "x" }, desc = "Append @this to OpenCode prompt" },
      { "<leader>at", function()
        require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
      end, mode = { "n", "t" }, desc = "Toggle OpenCode" },
      { "<leader>af", function()
        require("snacks.terminal").focus(opencode_cmd, snacks_terminal_opts)
      end, desc = "Focus OpenCode" },
      { "go", function()
        return require("opencode").operator("@this ")
      end, mode = { "n", "x" }, expr = true, desc = "Append range to OpenCode" },
      { "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, expr = true, desc = "Append line to OpenCode" },
      { "<C-.>", function()
        require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
      end, mode = { "n", "t" }, desc = "Toggle OpenCode" },
    },
    config = function()
      -- Bring the TUI back into view when OpenCode starts executing
      vim.api.nvim_create_autocmd("User", {
        pattern = { "OpencodeEvent:session.execution.started" },
        callback = function()
          local win = require("snacks.terminal").get(opencode_cmd, { create = false })
          if win then
            win:show()
          end
        end,
      })
    end,
  },
  {
    -- Nest the maps above under a named which-key group
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { mode = { "n", "x" }, "<leader>a", group = "opencode", icon = "󰚩" },
      },
    },
  },
  {
    -- Send files/lines from any snacks picker to opencode with <a-o>
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<a-o>"] = { "opencode_send", mode = { "n", "i" } },
            },
          },
        },
        actions = {
          opencode_send = function(picker) ---@param picker snacks.Picker
            local items = vim.tbl_map(function(item) ---@param item snacks.picker.Item
              return item.file
                and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                or item.text
            end, picker:selected({ fallback = true }))

            require("opencode").prompt(table.concat(items, ", ") .. " ")
          end,
        },
      },
    },
  },
}
