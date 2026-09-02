return {
  {
    'shaunchander/hunk-review.nvim',
    dependencies = { 'folke/snacks.nvim' },
    cmd = 'HunkReview',
    keys = {
      { '<leader>gR', '<cmd>HunkReview<cr>', desc = 'AI Code Review (diff vs base branch)' },
    },
    opts = {
      -- Prepended to the clipboard export so it can be pasted straight into
      -- the coding agent (Crush / Claude Code / Codex) after review.
      custom_prompt = 'The following is a code review of your changes. For every comment, apply the requested fix or briefly explain why not. Do not reformat code that was not commented on.',
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
    end,
  },
}
