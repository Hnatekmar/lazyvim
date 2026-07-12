return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- Disable the source selector panel (filesystem/buffers/git tabs at the top)
    -- Setting this to `false` triggers a neo-tree v3→v4 deprecation migration
    -- crash, because the migration code tries to traverse source_selector.tab_labels.
    -- An empty table achieves the same result (no source selector visible).
    source_selector = {},
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
