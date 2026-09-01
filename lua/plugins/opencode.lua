-- opencode.nvim — Neovim bridge to the opencode AI agent (opencode.ai).
--
-- Works against opencode's server API rather than scraping the TUI:
--   - Prompts accept context placeholders (@this, @buffer, @diagnostics,
--     @marks, @quickfix, @visible) with completion/highlighting in the ask
--     input (via snacks.input, which LazyVim already enables).
--   - Edits made by opencode reload open buffers live; edit-permission
--     requests open a side-by-side :diffpatch review tab.
--   - Prompts/operators are range-aware and dot-repeatable.
--
-- Requirements: `opencode` >= 1.17 on PATH. Servers must run with `--port`
-- (the snacks.terminal integration below starts one on demand). Verify with
-- `:checkhealth opencode`.
--
-- Keymaps (the `<leader>a` group, matching LazyVim's AI extras convention):
--   <leader>aa         Ask OpenCode (@this = selection or cursor position)
--   <leader>ac         Pick prompt/command/server (snacks.picker powered)
--   <leader>a,         Append @this to the TUI prompt without submitting
--   <leader>at         Toggle the opencode TUI (right-side snacks terminal)
--   <leader>af         Focus the opencode TUI
--   <leader>an         New session
--   <leader>aS         Switch session
--   <leader>ax         Interrupt the running agent
--   <C-.>              Alias of <leader>at (handy mid-typing)
--   go (operator)      Append motion/textobject range to the prompt
--   goo                Append current line
--   <S-C-u>/<S-C-d>    Scroll the opencode session
--   <a-o> (in picker)  Send selected file(s)/lines to opencode
--
-- Unlike the plugin's recommended maps, nothing here shadows Neovim
-- defaults: <C-a>/<C-x> still increment/decrement. Only the rarely-used
-- `go` byte-offset jump is shadowed by the operator.

local opencode_cmd = "opencode --port"

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
    version = "*", -- latest stable release
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
      { "<leader>an", function()
        require("opencode").command("session.new")
      end, desc = "OpenCode new session" },
      { "<leader>aS", function()
        require("opencode").command("session.select")
      end, desc = "OpenCode switch session" },
      { "<leader>ax", function()
        require("opencode").command("session.interrupt")
      end, desc = "OpenCode interrupt" },
      { "go", function()
        return require("opencode").operator("@this ")
      end, mode = { "n", "x" }, expr = true, desc = "Append range to OpenCode" },
      { "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, expr = true, desc = "Append line to OpenCode" },
      { "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, desc = "Scroll OpenCode up" },
      { "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, desc = "Scroll OpenCode down" },
      { "<C-.>", function()
        require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
      end, mode = { "n", "t" }, desc = "Toggle OpenCode" },
    },
    config = function()
      -- Bring the TUI back into view when a prompt is submitted
      vim.api.nvim_create_autocmd("User", {
        pattern = { "OpencodeEvent:tui.command.execute" },
        callback = function(args)
          ---@type opencode.server.Event
          local event = args.data.event
          if event.properties.command == "prompt.submit" then
            local win = require("snacks.terminal").get(opencode_cmd, { create = false })
            if win then
              win:show()
            end
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
