return {
  {
    'shaunchander/hunk-review.nvim',
    dependencies = { 'folke/snacks.nvim' },
    cmd = 'HunkReview',
    keys = {
      { '<leader>gR', '<cmd>HunkReview<cr>', desc = 'AI Code Review (diff vs base branch)' },
    },
    opts = {
      -- Prepended to the review payload so it can be pasted straight into
      -- the coding agent (Crush / Claude Code / Codex) after review.
      custom_prompt = 'The following is a code review of your changes. For every comment, apply the requested fix or briefly explain why not. Do not reformat code that was not commented on.',
      -- Every copy (<CR>) is also written here so clipboard-less consumers
      -- (Hermes agent over Telegram/SSH) can be pointed at the file instead.
      -- Relative paths resolve against nvim's cwd (repo root in normal use).
      export_file = '.git/hunk-review.md',
    },
    config = function(_, opts)
      local hr = require('hunk-review')
      hr.setup(opts)

      -- Plugin bug (upstream): detect_target_branch spawns `gh pr view`
      -- unconditionally to find a GitHub stacked-PR base, and the spawn
      -- throws ENOENT when the gh binary is missing — so the documented
      -- `git @{upstream}` fallback never runs and :HunkReview crashes on
      -- GitLab-only machines. Until fixed upstream, skip the gh step
      -- entirely when gh is not installed.
      if vim.fn.executable('gh') == 0 then
        local git = require('hunk-review.git')
        git.detect_target_branch = function(root, cached)
          if cached ~= nil then
            return cached
          end
          local out = vim.system({ 'git', '-C', root, 'rev-parse', '--abbrev-ref', '@{upstream}' }, { text = true }):wait()
          if out.code == 0 and out.stdout then
            local stripped = vim.trim(out.stdout):match('^[^/]+/(.+)$')
            if stripped and stripped ~= '' then
              return stripped
            end
          end
          return false
        end
      end

      -- Mirror the review text to a file on every copy. clipboard_text is the
      -- single choke point <CR> flows through, so hooking it there covers the
      -- whole copy path without touching keymaps.
      local exp = require('hunk-review.export')
      if not exp._file_mirror and type(exp.clipboard_text) == 'function' then
        local orig = exp.clipboard_text
        exp.clipboard_text = function(hunks, comments, prompt)
          local text = orig(hunks, comments, prompt)
          if text then
            local path = opts.export_file or '.git/hunk-review.md'
            if path:sub(1, 1) ~= '/' then
              path = vim.fn.getcwd() .. '/' .. path
            end
            if pcall(vim.fn.writefile, vim.split(text, '\n', { plain = true }), path) then
              vim.notify('Review written to ' .. path, vim.log.levels.INFO, { title = 'hunk-review.nvim' })
            end
          end
          return text
        end
        exp._file_mirror = true
      end
    end,
  },
}
