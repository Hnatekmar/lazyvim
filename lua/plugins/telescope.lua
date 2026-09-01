return {
  "nvim-telescope/telescope.nvim",
  opts = {
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = true,
      },
      live_grep = {
        additional_args = function()
          return { "--hidden", "--no-ignore" }
        end,
      },
      grep_string = {
        additional_args = function()
          return { "--hidden", "--no-ignore" }
        end,
      },
    },
  },
}
