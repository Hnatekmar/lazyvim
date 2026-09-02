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
  },
}
