-- repo_context.lua — cross-file FIM context for minuet
--
-- The problem: minuet sends one buffer (whole file up to the cursor, then the
-- rest). Everything defined in that file is already in the prompt, so the only
-- information a completion can be missing is a symbol defined in *another*
-- file: a helper, a constant, a type.
--
-- What this does: finds `obj.method(` call sites in the buffer, asks the LSP
-- where each method is defined, and caches a small, deterministic block of
-- "the defining file's head + the definition's neighbourhood" as
-- `<filename>…` sections. minuet prepends it to the FIM prompt.
--
-- Why file bodies and not a symbol list: Mellum 2's repo-context FIM was
-- trained on concatenated files marked with `<filename>` (tech report §4.2),
-- so bodies are in-distribution and a signature list is not.
--
-- Never call this from the completion hot path: everything except `get()` runs
-- on BufEnter / BufWritePost / LspAttach, debounced, off the keystroke.

local M = {}

M.opts = {
  max_chars = 2400, -- total injected context, hard cap
  max_calls = 12, -- LSP definition requests per refresh
  max_files = 3, -- distinct defining files kept
  -- Window shape is load-bearing, measured on 20 held-out cross-module calls:
  --   2 before / 10 after  -> 12/20 right callee, 4/20 degenerate  (chosen)
  --   1 / 5                -> 13/20, 5/20
  --   4 / 16               -> 14/20, 9/20  (wider costs stability, not helps)
  pre_lines = 2, -- decorator / doc comment above the definition
  post_lines = 10, -- signature + body
  debounce_ms = 1500,
  enabled = true,
}

local cache = {} -- bufnr -> string
local timers = {} -- bufnr -> uv_timer_t
local inflight = {} -- bufnr -> true

local function buf_path(bufnr)
  if vim.bo[bufnr].buftype ~= "" then
    return nil
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end
  return name
end

-- Call sites of the form `obj.method(` or `obj:method(`. Those are the only
-- ones that can resolve into another file; bare `foo(` is usually local and
-- already visible to the model.
-- @return list of { line = 0-based, character = 0-based byte col, name = string }
function M.call_candidates(lines, limit)
  local out = {}
  for i, l in ipairs(lines) do
    local init = 1
    while true do
      local s, e, name = l:find("[:.]([%a_][%w_]*)%s*%(", init)
      if not s then
        break
      end
      -- `s` is the separator byte; the identifier starts at the next byte,
      -- whose 0-based column equals `s`.
      out[#out + 1] = { line = i - 1, character = s, name = name }
      if #out >= limit then
        return out
      end
      init = e + 1
    end
  end
  return out
end

local function read_lines(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= "table" or #lines == 0 then
    return nil
  end
  return lines
end

-- A window around the definition, and nothing else.
--
-- Measured, not assumed: including the defining file's head (imports,
-- `local M = {}`) plus a "..." gap marker made the model treat the prompt as a
-- file to continue and it emitted `M.` / variable loops — 0/20 cases named the
-- right callee. A tight window around the definition reads as documentation
-- and scored 15/20. Do not reintroduce a file preamble.
function M.extract(path, target, opts)
  local lines = read_lines(path)
  if not lines then
    return nil
  end
  target = target or 0
  -- LSP lines are 0-based, vim.fn.readfile returns 1-based lists.
  local from = math.max(1, target + 1 - opts.pre_lines)
  local to = math.min(#lines, target + 1 + opts.post_lines)
  if from > to then
    return nil
  end
  local parts = {}
  for i = from, to do
    parts[#parts + 1] = lines[i]
  end
  return parts
end

-- Deterministic, budgeted composition. Sorted by path so the rendered string
-- is byte-identical between keystrokes and vLLM's prefix cache keeps hitting.
function M.compose(entries, opts)
  table.sort(entries, function(a, b)
    return a.path < b.path
  end)
  local parts, total = {}, 0
  for _, e in ipairs(entries) do
    local name = vim.fs.basename(e.path)
    local block = "<filename>" .. name .. "\n" .. table.concat(e.lines, "\n") .. "\n"
    if total + #block > opts.max_chars then
      break
    end
    parts[#parts + 1] = block
    total = total + #block
  end
  return table.concat(parts)
end

local function gather(bufnr)
  local opts = M.opts
  local path = buf_path(bufnr)
  if not path then
    return ""
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/definition" })
  if #clients == 0 then
    return ""
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cands = M.call_candidates(lines, opts.max_calls)
  if #cands == 0 then
    return ""
  end

  local uri = vim.uri_from_bufnr(bufnr)
  local found = {} -- uri -> smallest definition line seen
  local remaining = #cands
  local done = false

  local function finish()
    if done then
      return
    end
    done = true
    local entries = {}
    for u, lnum in pairs(found) do
      local p = vim.uri_to_fname(u)
      local is_other_file = p ~= path and not p:match("^%w+://")
      if is_other_file then
        local chunk = M.extract(p, lnum, opts)
        if chunk then
          entries[#entries + 1] = { path = p, lines = chunk }
        end
      end
    end
    -- keep the first N deterministically, not by table order
    table.sort(entries, function(a, b)
      return a.path < b.path
    end)
    while #entries > opts.max_files do
      table.remove(entries)
    end
    cache[bufnr] = M.compose(entries, opts)
    inflight[bufnr] = nil
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_exec_autocmds("User", { pattern = "RepoContextReady", buffer = bufnr })
    end
  end

  for _, c in ipairs(cands) do
    local params = { textDocument = { uri = uri }, position = { line = c.line, character = c.character } }
    local ok = pcall(vim.lsp.buf_request, bufnr, "textDocument/definition", params, function(err, res)
      if not err and type(res) == "table" then
        for _, loc in ipairs(res) do
          local u = loc.uri or loc.targetUri
          local rng = loc.range or loc.targetRange
          if u then
            local lnum = rng and rng.start and rng.start.line or 0
            if found[u] == nil or lnum < found[u] then
              found[u] = lnum
            end
          end
        end
      end
      remaining = remaining - 1
      if remaining <= 0 then
        finish()
      end
    end)
    if not ok then
      remaining = remaining - 1
      if remaining <= 0 then
        finish()
      end
    end
  end
end

function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.opts.enabled or inflight[bufnr] then
    return
  end
  inflight[bufnr] = true
  local ok, err = pcall(gather, bufnr)
  if not ok then
    inflight[bufnr] = nil
    vim.notify("repo_context: " .. tostring(err), vim.log.levels.DEBUG)
  end
end

-- Called from the minuet prompt function. Returns "" until the first refresh
-- lands, and schedules one if the buffer has none — the request itself never
-- waits for LSP.
function M.get(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  local cached = cache[bufnr]
  if cached ~= nil then
    return cached
  end
  cache[bufnr] = ""
  vim.schedule(function()
    M.refresh(bufnr)
  end)
  return ""
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  local group = vim.api.nvim_create_augroup("RepoContext", { clear = true })

  local function schedule(bufnr)
    if not M.opts.enabled then
      return
    end
    if timers[bufnr] then
      timers[bufnr]:stop()
    else
      timers[bufnr] = vim.uv.new_timer()
    end
    timers[bufnr]:start(
      M.opts.debounce_ms,
      0,
      vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          M.refresh(bufnr)
        end
      end)
    )
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = group,
    callback = function(args)
      schedule(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      schedule(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      cache[args.buf] = nil
      if timers[args.buf] then
        timers[args.buf]:stop()
        timers[args.buf] = nil
      end
    end,
  })
end

return M
