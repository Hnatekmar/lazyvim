return {
  {
    'taigrr/neocrush.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'taigrr/glaze.nvim',
    },
    event = 'VeryLazy',
    opts = {
      terminal_width = 80,
      keys = {
        toggle = '<leader>cc',
        focus = '<leader>cf',
      },
    },
  },
}
