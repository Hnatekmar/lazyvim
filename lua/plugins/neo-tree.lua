return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- Disable the source selector panel (filesystem/buffers/git tabs at the top)
    -- Use :Neotree buffers or :Neotree git_status if you ever need those views
    source_selector = false,
    filesystem = {
      filtered_items = {
        visible = true, -- show hidden files (dotfiles)
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },
    window = {
      mappings = {
        ["<space>"] = "none",
      },
    },
  },
}
