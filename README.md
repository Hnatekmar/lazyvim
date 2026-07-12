# 💤 LazyVim — Custom Configuration

A personalized [LazyVim](https://github.com/LazyVim/LazyVim) Neovim configuration optimized for **Python**, **Go**, **Kubernetes**, **Helm**, **Terraform**, and **TypeScript** development.

## ✨ Features

- **Python** — basedpyright LSP with tuned diagnostics
- **Go** — Full gopls support via LazyVim extras
- **Kubernetes** — `kubernetes.nvim` with schema validation and YAML LSP integration
- **Helm** — `helm-schemas.nvim` for template stubs, CRD sync, and SchemaStore integration
- **YAML** — Multi-schema YAML LSP with K8s awareness
- **Neorg** — Structured note-taking and organization
- **AI-powered completion** — Mini.ai + blink.cmp + minuet (AI inline completions)
- **Noice** — Modern UI notifications and command line
- **Neo-tree** — File explorer with git status
- **basedpyright** — Replaces standard pyright for stricter Python analysis

## 📋 Prerequisites

- **Neovim >= 0.9.0** (recommended: 0.10+)
- **Git**
- **Nerd Font** (for icons — e.g., [JetBrainsMono Nerd Font](https://www.nerdfonts.com/))
- **Optional but recommended:**
  - `lazygit` — Git UI integration
  - `ripgrep` (rg) — Fast fuzzy search (Telescope)
  - `fd` — File finder (Telescope)
  - `basedpyright` — Python LSP (install via pip or system package manager)

## 🚀 Installation

### 1. Backup your existing Neovim config (optional but recommended)

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
```

### 2. Clone the configuration

```bash
git clone https://github.com/Hnatekmar/lazyvim.git ~/.config/nvim
```

### 3. Install language servers (as needed)

```bash
# Python
pip install basedpyright

# Go (via gopls)
go install golang.org/x/tools/gopls@latest

# Kubernetes / Helm
# helm-ls — https://github.com/mrjosh/helm-ls
# yaml-language-server — npm install -g yaml-language-server

# Terraform
# terraform-ls — https://github.com/hashicorp/terraform-ls
```

### 4. Start Neovim

```bash
nvim
```

Lazy.nvim will automatically download and install all plugins on first launch. Wait for the installation to complete (you'll see the Lazy dashboard).

### 5. Verify installation

Run `:Lazy` to see the plugin manager dashboard. All plugins should show as installed.

## 🔧 Customization

This configuration is organized for easy customization:

```
~/.config/nvim/
├── init.lua              # Entry point
├── lazyvim.json          # LazyVim extras configuration
├── lua/
│   ├── config/
│   │   ├── autocmds.lua  # Auto-commands (auto-create dirs, yank highlight, etc.)
│   │   ├── keymaps.lua   # Custom keybindings
│   │   ├── lazy.lua      # Plugin manager bootstrap
│   │   └── options.lua   # Editor options
│   └── plugins/
│       ├── blink.lua      # Auto-completion UI
│       ├── helm-schemas.lua # Helm template schemas
│       ├── kubernetes.lua # K8s YAML validation
│       ├── minuet.lua     # AI inline completion
│       ├── neo-tree.lua   # File explorer
│       ├── neorg.lua      # Note-taking
│       ├── noice.lua      # UI notifications
│       ├── python.lua     # Python LSP (basedpyright)
│       └── yaml.lua       # YAML LSP configuration
└── stylua.toml           # Lua formatting config
```

> 💡 See [PLUGINS.md](PLUGINS.md) for a complete reference of every plugin in this configuration — what they do, quickstart tips, and links to their original repos.

### Adding new plugins

Create a new file in `lua/plugins/` and return a plugin spec:

```lua
return {
  "author/plugin-name",
  opts = {
    -- plugin options
  },
}
```

### Enabling LazyVim extras

Edit `lazyvim.json` and add the extra name to the `extras` array.

## ⌨️ Custom Keymaps

| Key       | Action                        | Mode |
|-----------|-------------------------------|------|
| `]q`      | Next quickfix item            | Normal |
| `[q`      | Previous quickfix item        | Normal |
| `jk`      | Exit terminal insert mode     | Terminal |

## 🐛 Troubleshooting

### Plugins not showing / errors on startup

Run `:Lazy clean` and `:Lazy sync` to ensure all plugins are properly installed.

### LSP not starting

Ensure the language server is installed and available in your `PATH`:

```bash
which basedpyright   # Python
which gopls           # Go
which yaml-language-server  # YAML
```

### Missing icons

Install a [Nerd Font](https://www.nerdfonts.com/) and set it as your terminal font.

## 📄 License

Apache 2.0 — see [LICENSE](LICENSE).
