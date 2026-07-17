# 📦 Plugin Reference

This document describes every plugin and LazyVim extra used in this configuration — what they do, quickstart tips, and links to their original repositories.

---

## 🧱 Core Framework

### [LazyVim](https://github.com/LazyVim/LazyVim)
The base Neovim distribution that this config builds on top of. Provides sane defaults, a modular plugin structure, and a curated set of quality-of-life plugins.

- **Quickstart**: Installed automatically via `lazy.nvim`. Run `:Lazy` to see the plugin manager dashboard.
- **Docs**: https://lazyvim.github.io

### [lazy.nvim](https://github.com/folke/lazy.nvim)
A modern plugin manager for Neovim. Handles installation, lazy-loading, updates, and dependency management.

- **Quickstart**: Bootstrapped on first launch. Run `:Lazy` for the UI. Use `:Lazy update` to update all plugins, `:Lazy sync` to sync lockfile.

---

## 🎨 UI & Appearance

### [catppuccin](https://github.com/catppuccin/nvim)
Soothing pastel color scheme (the default theme).

- **Quickstart**: Applied automatically. Change via `vim.cmd.colorscheme("tokyonight")` in `options.lua` if you prefer.

### [tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
A clean, dark Neovim theme inspired by the Atom One Dark / Tokyo Night color palette. Available as an alternative to Catppuccin.

### [noice.nvim](https://github.com/folke/noice.nvim)
Replaces the default Neovim UI with a modern, notifications-based command line, messages, and popups.

- **Quickstart**: Works out of the box. LSP progress notifications are disabled in this config (set `enabled = false`).

### [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
A snazzy buffer line (tab bar) that sits at the top of the editor.

- **Quickstart**: Navigate buffers with `:bnext` / `:bprev`. No custom config in this setup.

### [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
A blazing-fast statusline written in pure Lua.

- **Quickstart**: Configured automatically by LazyVim. No overrides in this config.

### [dressing.nvim](https://github.com/stevearc/dressing.nvim)
Improves the built-in `vim.ui` interfaces (input, select, confirm) with a cleaner look.

- **Quickstart**: Works transparently — `vim.ui.input()`, `vim.ui.select()`, etc. look better automatically.

### [mini.icons](https://github.com/echasnovski/mini.icons)
Icon provider used by Neo-tree, Lualine, and other plugins.

- **Quickstart**: Automatic. Ensure you have a [Nerd Font](https://www.nerdfonts.com/) installed.

### [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
File-type icon provider. Used by Neo-tree and other file explorers.

---

## ⌨️ Editing & Completion

### [blink.cmp](https://github.com/saghen/blink.cmp)
A performant, minimal autocompletion UI.

- **Quickstart**:
  - `<Tab>` / `<S-Tab>` — Navigate completion items
  - `<A-y>` — Trigger AI inline completions (configured in blink.lua, sources: minuet)
  - Sources: LSP, path, buffer
- **Repo**: https://github.com/saghen/blink.cmp

### [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim)
AI-powered inline code completions (ghost text), similar to GitHub Copilot. Configured to use a local vLLM endpoint serving DeepSeek-V4-Flash.

- **Quickstart**: Accept ghost text with `<Tab>`. The completion appears automatically after a brief pause.
- **Note**: The `api_key` is set to `"TERM"` — the bot reads it from stdin or a terminal prompt. Configure your actual key via env var or terminal input.
- **Config**: `lua/plugins/minuet.lua`

### [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
A snippet engine for Neovim. Integrates with blink.cmp for snippet expansion.

- **Quickstart**: Enabled via the `lazyvim.plugins.extras.coding.luasnip` extra. Snippet collections come from `friendly-snippets`.

### [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
A community-maintained collection of snippets for many languages.

- **Quickstart**: Loaded automatically alongside LuaSnip. Trigger snippets via completion menu.

### [mini.ai](https://github.com/echasnovski/mini.ai)
Extends the built-in `a` and `i` text-objects with smart, context-aware selections (e.g., `ai` around function argument, `ii` inside indent).

- **Quickstart**: Works automatically. Try `vai` (visual around argument), `cii` (change inside indent).

### [mini.pairs](https://github.com/echasnovski/mini.pairs)
Auto-pairs for brackets, quotes, and other delimiters.

- **Quickstart**: Automatic. Typing `(` auto-closes with `)`.

### [ts-comments.nvim](https://github.com/folke/ts-comments.nvim)
Comment toggling powered by Treesitter — knows the correct comment syntax for every language.

- **Quickstart**: `gcc` to toggle comment on current line, `gc` in visual mode.

## 🔍 Fuzzy Finding & Navigation

### [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
A highly extendable fuzzy finder over lists. Used for finding files, grepping, buffers, help tags, and more.

- **Quickstart**:
  - `<leader>ff` — Find files
  - `<leader>fg` — Live grep (search text in files)
  - `<leader>fb` — List buffers
  - `<leader>fh` — Help tags

### [flash.nvim](https://github.com/folke/flash.nvim)
Navigate your code with a search-and-jump interface. Highlights possible targets as you type.

- **Quickstart**: Press `s` and start typing to see jump labels. Press the label to jump.

### [fzf-lua](https://github.com/ibhagwan/fzf-lua)
Alternative fuzzy finder using the fzf binary. Not the primary picker in this config (Telescope is default), but available.

### [mini.pick](https://github.com/echasnovski/mini.pick)
A minimal fuzzy picker alternative. Installed as part of LazyVim but Telescope is the default.

### [lazydev.nvim](https://github.com/folke/lazydev.nvim)
Configures Lua LSP (lua-language-server) to understand lazy.nvim plugin specs and Neovim runtime files.

- **Quickstart**: Automatic. Gives you full autocompletion and type checking inside Lua config files.

## 📁 File Explorer

### [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
A file explorer with git status indicators, file icons, and filtering.

- **Quickstart**:
  - `<leader>e` — Toggle file explorer
  - `<leader>E` — Focus file explorer
  - Config: `lua/plugins/neo-tree.lua`
  - Shows hidden files by default (dotfiles visible)
  - Follows the current file automatically

## 🔧 Language Support — LSP & Tooling

### [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
The standard collection of configurations for the built-in LSP client. This config customizes `basedpyright` and `yamlls`.

- **Quickstart**: Language servers start automatically when you open a supported file.
- **Custom configs**:
  - `lua/plugins/python.lua` — basedpyright settings
  - `lua/plugins/yaml.lua` — yamlls multi-schema setup

### [mason.nvim](https://github.com/williamboman/mason.nvim)
Portable package manager for Neovim — installs LSP servers, linters, formatters, and DAP adapters.

- **Quickstart**: `:Mason` to browse and install packages. Servers listed in `lua/plugins/*.lua` are auto-installed.

### [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
Bridge between `mason.nvim` and `nvim-lspconfig` — auto-installs and configures LSP servers.

### [conform.nvim](https://github.com/stevearc/conform.nvim)
A lightweight code formatter runner. Integrates with LazyVim's formatting setup.

- **Quickstart**: Format on save by default. `<leader>cf` to format manually.

### [nvim-lint](https://github.com/mfussenegger/nvim-lint)
A simple async linter integration for Neovim.

- **Quickstart**: Works alongside LSP diagnostics. Lints on save.

### [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
Treesitter integration for Neovim — provides better syntax highlighting, code folding, and structural navigation.

- **Quickstart**: Automatic. Run `:TSInstall <language>` to install parsers for additional languages.

### [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
Create text objects based on Treesitter AST nodes (e.g., select inner function body, around class).

- **Quickstart**: Works automatically. Try `vaf` (visual around function), `vif` (inside function).

### [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)
Auto-close and auto-rename HTML/XML/JSX tags using Treesitter.

### [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)
Provides JSON Schema catalog for YAML LSP.

- **Quickstart**: Used by yamlls via `schemaStore.enable = true`.

## ☸️ Kubernetes & Helm

### [kubernetes.nvim](https://github.com/diogo464/kubernetes.nvim)
Kubernetes resource validation and YAML schema management within Neovim.

- **Quickstart**:
  - `:KubernetesGenerateSchema` — Manually regenerate K8s schema
  - Automatically patches yamlls to avoid "Matches multiple schemas" errors
  - Config: `lua/plugins/kubernetes.lua`

### [helm-schemas.nvim](https://github.com/gijsentius/helm-schemas.nvim)
Helm chart templating support with Kubernetes resource stubs and SchemaStore integration.

- **Quickstart**:
  - `<leader>hs` — Template picker (insert K8s resource stubs)
  - `<leader>hc` — Live cluster CRD sync (pulls schemas from active kubectl context)
  - `<leader>hC` — Add CRD from file or URL
  - `<leader>hS` — Sync SchemaStore templates
  - `<leader>hk` — Core K8s types
  - `<leader>hd` — Sync datreeio CRD schemas
  - `<leader>hx` — Clear schemas
  - Config: `lua/plugins/helm-schemas.lua`

### [helm-ls.nvim](https://github.com/mrjosh/helm-ls.nvim)
Helm language server integration (requires `helm_ls` binary).

- **Quickstart**: Automatic when editing `*.yaml` files inside Helm chart directories.

## 🧪 Debugging (DAP)

### [nvim-dap](https://github.com/mfussenegger/nvim-dap)
Debug Adapter Protocol client for Neovim. The foundation for debugging in this config.

- **Quickstart**: See language-specific DAP plugins below.

### [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
A graphical UI for DAP — shows breakpoints, stack frames, variables, and watches.

- **Quickstart**: `<leader>du` to toggle the DAP UI panel.

### [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text)
Displays variable values as virtual text inline while debugging.

- **Quickstart**: Automatic when a debug session is active.

### [nvim-dap-go](https://github.com/leoluz/nvim-dap-go)
DAP adapter for Go (uses `delve` under the hood).

- **Quickstart**: Set breakpoints with `<leader>db`, start with `<leader>dc`.

### [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
DAP adapter for Python (uses `debugpy`).

### [one-small-step-for-vimkind](https://github.com/jbyuki/one-small-step-for-vimkind)
A DAP adapter for debugging Lua code running in Neovim itself. Useful for plugin development.

## 📝 Note-Taking & Writing

### [neorg](https://github.com/nvim-neorg/neorg)
A structured note-taking and organization system using the `.norg` file format.

- **Quickstart**:
  - Create a `.norg` file
  - Use `:Neorg keybinds` to see available keymaps
  - Config: `lua/plugins/neorg.lua`

### [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
Renders Markdown content inline in Neovim with formatting, headings, and code blocks.

- **Quickstart**: Automatic when opening `.md` files.

### [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
Preview rendered Markdown in a browser.

- **Quickstart**: `:MarkdownPreview` to open the preview, `:MarkdownPreviewStop` to close.

## 🔁 Git Integration

### [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
Shows git diff markers in the signcolumn (added/changed/removed lines).

- **Quickstart**: Automatic. Use `]c` / `[c` to jump between hunks.

### [trouble.nvim](https://github.com/folke/trouble.nvim)
A pretty diagnostic, references, and quickfix list viewer.

- **Quickstart**:
  - `<leader>xx` — Toggle trouble (diagnostics)
  - `<leader>xw` — Workspace diagnostics
  - `<leader>xq` — Quickfix list
  - Config is managed by LazyVim.

### [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)
Highlights and lists TODO, FIXME, HACK, NOTE comments in your code.

- **Quickstart**: `<leader>xt` to open the todo-comments panel.

### [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim)
Search and replace across files (a modern alternative to `:cdo`).

- **Quickstart**: `:GrugFar` to open the search-and-replace UI. Supports regex.

## 🧰 Utility Plugins

### [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
A utility library providing async I/O, HTTP requests, paths, and more. Used by many other plugins as a dependency.

### [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
UI component library for Neovim popups, menus, and inputs. Used by noice.nvim and other UI plugins.

### [snacks.nvim](https://github.com/folke/snacks.nvim)
A collection of small, focused quality-of-life improvements (better notifications, indent guides, dashboard, etc.).

### [which-key.nvim](https://github.com/folke/which-key.nvim)
Displays available keybindings as you type a leader prefix.

- **Quickstart**: Press `<leader>` and wait a moment — a popup shows all available commands.

### [persistence.nvim](https://github.com/folke/persistence.nvim)
Session management — automatically saves and restores your Neovim session.

- **Quickstart**: Automatic. Use `:SessionRestore` to restore a saved session.

### [pathlib.nvim](https://github.com/echasnovski/pathlib.nvim)
A path manipulation library for Lua, providing ergonomic file path operations.

### [lua-utils.nvim](https://github.com/echasnovski/lua-utils.nvim)
Utility functions for Lua development in Neovim.

### [nvim-nio](https://github.com/nvim-neotest/nvim-nio)
A library for async IO operations in Neovim, used by DAP and other plugins.

### [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim)
Python virtual environment selector — automatically picks up and activates the right venv for your project.

- **Quickstart**: `<leader>vs` to select a virtual environment manually. Otherwise automatic.

### [hererocks](https://github.com/mpeterv/hererocks)
LuaRocks manager for Neovim — installs Lua dependencies needed by some plugins.

## 🧩 LazyVim Extras (Enabled)

These extras are enabled in `lazyvim.json` and bring in additional functionality:

| Extra | Description |
|-------|-------------|
| `coding.luasnip` | Snippet engine (LuaSnip + friendly-snippets) |
| `dap.core` | Core DAP debugging support |
| `dap.nlua` | Lua debugging support via nlua |
| `lang.docker` | Dockerfile LSP & Treesitter |
| `lang.go` | Go LSP (gopls), formatting, and debugging |
| `lang.helm` | Helm chart support via helm-ls |
| `lang.json` | JSON LSP & schema support |
| `lang.markdown` | Markdown LSP & preview |
| `lang.python` | Python LSP (pyright → basedpyright) |
| `lang.terraform` | Terraform LSP & formatting |
| `lang.toml` | TOML LSP & Treesitter |
| `lang.typescript` | TypeScript/JavaScript LSP (ts_ls) |
| `lang.yaml` | YAML LSP with SchemaStore |

For more details on each extra, see the [LazyVim extras documentation](https://github.com/LazyVim/LazyVim/tree/main/lua/lazyvim/plugins/extras).

## 🗂️ Custom Plugin Configurations

| File | Description | Link |
|------|-------------|------|
| `lua/plugins/blink.lua` | Autocompletion UI with minuet AI source | [blink.cmp](https://github.com/saghen/blink.cmp) |
| `lua/plugins/helm-schemas.lua` | Helm template stubs & CRD sync | [helm-schemas.nvim](https://github.com/gijsentius/helm-schemas.nvim) |
| `lua/plugins/kubernetes.lua` | K8s YAML schema validation | [kubernetes.nvim](https://github.com/diogo464/kubernetes.nvim) |
| `lua/plugins/minuet.lua` | AI inline completions via vLLM | [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim) |
| `lua/plugins/neo-tree.lua` | File explorer (hidden files visible) | [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) |
| `lua/plugins/neorg.lua` | Structured note-taking | [neorg](https://github.com/nvim-neorg/neorg) |
| `lua/plugins/noice.lua` | Modern UI (LSP progress disabled) | [noice.nvim](https://github.com/folke/noice.nvim) |
| `lua/plugins/python.lua` | basedpyright LSP settings | [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) |
| `lua/plugins/yaml.lua` | Multi-schema YAML LSP | [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) |

## ⌨️ Custom Keymaps

In addition to LazyVim defaults, this config adds these custom keymaps in `lua/config/keymaps.lua`:

| Key | Mode | Action |
|-----|------|--------|
| `]q` | Normal | Next quickfix item |
| `[q` | Normal | Previous quickfix item |
| `jk` | Terminal | Exit terminal mode |

---

*Last updated: July 2026*
