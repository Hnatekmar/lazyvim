-- Minuet AI config with LSP context injection
--
-- Adds a `lsp_context` placeholder to the chat_input template. On each
-- completion request, the function gathers:
--   1. Diagnostics on the cursor line (instant — no LSP round-trip)
--   2. Hover info at cursor (synchronous, 100ms timeout — type signatures, docs)
-- and formats them into a compact <lsp_context> block prepended to the prompt.
--
-- This gives Qwen 3.6 real semantic context (types, errors, signatures)
-- instead of relying purely on raw text lines around the cursor.

local M = {}

-- Maximum characters of LSP context to inject (keeps prompt lean)
local LSP_CONTEXT_LIMIT = 4000

-- Hover request timeout in milliseconds. Must be short — this blocks the
-- completion request. 100ms is enough for a local LSP; raise if your LSP
-- is remote.
local HOVER_TIMEOUT_MS = 100

--- Gather LSP context for the current cursor position.
--- Called synchronously by Minuet's template engine.
--- @param _ctx_before string  context before cursor (unused)
--- @param _ctx_after  string  context after cursor (unused)
--- @param _opts       table   minuet options (unused)
--- @return string     formatted LSP context block, or empty string
local function get_lsp_context(_ctx_before, _ctx_after, _opts)
    local parts = {}

    -- 1. Line diagnostics (instant — no LSP round-trip)
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(0, { lnum = cursor_line })
    if #diagnostics > 0 then
        local diags = {}
        for _, d in ipairs(diagnostics) do
            local sev = vim.diagnostic.severity[d.severity] or 'N'
            local prefix = sev:sub(1, 1):upper()
            table.insert(diags, string.format('  [%s] %s (col %d)', prefix, d.message, d.col + 1))
        end
        table.insert(parts, '<diagnostics>')
        table.insert(parts, table.concat(diags, '\n'))
        table.insert(parts, '</diagnostics>')
    end

    -- 2. Hover info (synchronous, short timeout)
    --    Gives type signatures, documentation, and symbol info at cursor.
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        local params = vim.lsp.util.make_position_params()
        local results = vim.lsp.buf_request_sync(0, 'textDocument/hover', params, HOVER_TIMEOUT_MS)
        if results then
            for _, res in ipairs(results) do
                if res.result and res.result.contents then
                    local contents = res.result.contents
                    -- LSP hover contents can be a string or a MarkupContent table
                    if type(contents) == 'string' then
                        if contents:match('%S') then
                            table.insert(parts, '<hover>')
                            table.insert(parts, contents)
                            table.insert(parts, '</hover>')
                        end
                    elseif type(contents) == 'table' then
                        -- MarkupContent: { kind = "markdown", value = "..." }
                        -- or array of MarkedString
                        if contents.value then
                            if contents.value:match('%S') then
                                table.insert(parts, '<hover>')
                                table.insert(parts, contents.value)
                                table.insert(parts, '</hover>')
                            end
                        else
                            local lines = {}
                            for _, item in ipairs(contents) do
                                if type(item) == 'string' then
                                    table.insert(lines, item)
                                elseif type(item) == 'table' and item.value then
                                    table.insert(lines, item.value)
                                end
                            end
                            if #lines > 0 then
                                table.insert(parts, '<hover>')
                                table.insert(parts, table.concat(lines, '\n'))
                                table.insert(parts, '</hover>')
                            end
                        end
                    end
                end
            end
        end
    end

    if #parts == 0 then
        return ''
    end

    local result = table.concat(parts, '\n')
    -- Truncate to limit
    if #result > LSP_CONTEXT_LIMIT then
        result = result:sub(1, LSP_CONTEXT_LIMIT) .. '\n... (truncated)'
    end

    return '<lsp_context>\n' .. result .. '\n</lsp_context>\n'
end

--- Build the LSP-aware system prompt addition
local lsp_system_addendum = [[
9. When <lsp_context> is provided, use it to:
   - Match types and signatures from <hover> exactly.
   - Address errors/warnings from <diagnostics> by offering completions
     that resolve them, when applicable.
   - Prefer identifiers (function names, field names) that the LSP has
     already recognized.
]]

function M.config()
    local mc = require 'minuet.config'

    -- Start from the default prefix-first system (OpenAI-compatible default)
    local system = vim.deepcopy(mc.default_system_prefix_first)
    system.template = system.template .. '\n' .. lsp_system_addendum

    -- Extend chat_input template with the lsp_context placeholder
    local chat_input = vim.deepcopy(mc.default_chat_input_prefix_first)
    chat_input.template =
        '{{{lsp_context}}}\n' ..
        '{{{language}}}\n{{{tab}}}\n' ..
        '<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n' ..
        '<contextAfterCursor>\n{{{context_after_cursor}}}'
    chat_input.lsp_context = get_lsp_context

    require('minuet').setup({
        provider = 'openai_compatible',
        request_timeout = 10,
        n_completions = 2,
        throttle = 1000,
        debounce = 50,
        context_window = 32000,
        add_single_line_entry = false,
        virtualtext = {
            auto_trigger_ft = { '*' },
            keymap = {
                accept = '<A-A>',
                accept_line = '<A-a>',
                accept_n_lines = '<A-z>',
                next = '<A-]>',
                prev = '<A-[>',
                dismiss = '<A-e>',
            },
        },
        provider_options = {
            openai_compatible = {
                api_key = 'TERM',
                end_point = 'https://proxy.personal-hermes.hnatekmar.dev/v1/chat/completions',
                model = 'qwen36-instruct',
                name = 'vllm',
                stream = true,
                system = system,
                chat_input = chat_input,
                few_shots = mc.default_few_shots_prefix_first,
                optional = {
                    max_tokens = 256,
                },
            },
        },
    })
end

return {
    {
        'milanglacier/minuet-ai.nvim',
        config = function()
            M.config()
        end,
    },
}
