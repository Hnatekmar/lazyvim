# Plugin Documentation

This document describes all plugins and extras used in this LazyVim configuration.

## Quickstart

1. Install: `git clone https://github.com/Hnatekmar/lazyvim.git ~/.config/nvim`
2. Open Neovim: `nvim` — Lazy.nvim will auto-install all plugins on first launch
3. Check status: `:Lazy` to see the plugin dashboard

---

## Custom Plugins (`lua/plugins/`)

### blink.cmp — Auto-Completion UI
- **Repository:** [saghen/blink.cmp](https://github.com/saghen/blink.cmp)
- **Dependencies:** [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- **Purpose:** Provides intelligent code completion with a modern UI. Handles LSP completions, snippet support, and integrates with Minuet AI for inline suggestions.
- **Keybindings:**
  - `<Tab>` — Select next completion
  - `<S-Tab>` — Select previous completion
  - `<A-y>` — Manually trigger Minuet AI completions (dropdown mode)
- **Notes:** Command-line completion is disabled. The completion menu only appears when explicitly triggered.

### helm-schemas — Helm Template Schemas
- **Repository:** [Currently disabled](https://github.com/mrjosh/helm-ls)
- **Status:** **DISABLED** — The plugin spec returns an empty table. Uncomment the block in `helm-schemas.lua` to enable.
- **Purpose:** Provides schema validation and template stubs for Helm chart files. Integrates with SchemaStore for CRD validation.

### kubernetes — Kubernetes YAML Support
- **Repository:** [diogo464/kubernetes.nvim](https://github.com/diogo464/kubernetes.nvim)
- **Purpose:** Provides Kubernetes YAML schema validation, LSP integration, and cluster management commands. Patches yamlls to allow multiple schemas (fixes "Matches multiple schemas" errors).
- **Features:**
  - Strict schema validation (`schema_strict = true`)
  - Schema generation on demand (`:KubernetesGenerateSchema`)
  - Automatic patching of yamlls for multi-schema support

### minuet — AI Inline Completions
- **Repository:** [milanglacier/minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim)
- **Purpose:** AI-powered inline code completions using an OpenAI-compatible API. Injects LSP context (diagnostics + hover info) into completion requests for smarter suggestions.
- **API Configuration:**
  - Endpoint: `https://proxy.personal-hermes.hnatekmar.dev/v1/chat/completions`
  - Model: `qwen36-instruct`
  - Context window: 32,000 tokens
  - Timeout: 5 seconds
- **LSP Context Injection:** On each completion request, gathers line diagnostics and hover information at the cursor position (up to 4,000 characters) and prepends it to the prompt as `<lsp_context>`.
- **Keybindings:**
  - `<A-CR>` — Accept completion
  - `<A-a>` — Accept current line
  - `<A-z>` — Accept N lines
  - `<A-n>` / `<A-p>` — Next/previous suggestion
  - `<A-e>` — Dismiss
- **Virtual text triggers:** Auto-triggers for all file types (`'*'`)

### neocrush — AI Image Compression
- **Repository:** [taigrr/neocrush.nvim](https://github.com/taigrr/neocrush.nvim)
- **Dependencies:** [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), [glaze.nvim](https://github.com/taigrr/glaze.nvim)
- **Purpose:** AI-powered image compression and optimization. Uses Telescope for browsing compressed images.
- **Keybindings:**
  - `<leader>cc` — Toggle neocrush panel
  - `<leader>cf` — Focus neocrush panel
- **Event:** Loads on `VeryLazy`

### neorg — Structured Note-Taking
- **Repository:** [nvim-neorg/neorg](https://github.com/nvim-neorg/neorg)
- **Dependencies:** [plenary.nvim](https://github.com/nvim-lua/plenary.nvim), [luarocks.nvim](https://github.com/vhyrro/luarocks.nvim)
- **Purpose:** A powerful note-taking and organization system inside Neovim. Supports structured documents, task management, and bi-directional linking.
- **Setup:** Built on startup (`:Neorg sync-parsers`). Loads eagerly (`lazy = false`).

### neo-tree — File Explorer
- **Repository:** [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
- **Purpose:** File explorer with git status integration, buffer management, and tree view.
- **Configuration:**
  - Shows hidden files (dotfiles) and gitignored files
  - Follows the current file in the editor
  - Uses libuv file watcher for real-time updates
  - Source selector (filesystem/buffers/git tabs) is disabled
  - `<space>` mapping is disabled in the tree

### noice — Modern UI Notifications
- **Repository:** [folke/noise.nvim](https://github.com/folke/noice.nvim)
- **Purpose:** Replaces Neovim's default messages, cmdline, and notifications with a modern, overlay-based UI. Provides better visibility for LSP progress, search results, and command output.
- **Configuration:** LSP progress messages are disabled to reduce noise.

### python — Python LSP (basedpyright)
- **Repository:** [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- **Purpose:** Python language server using [basedpyright](https://github.com/robherring/basedpyright) (a fork of Microsoft's pyright with enhanced features).
- **Settings:**
  - Type checking mode: `standard`
  - Suppresses `reportUnknownVariableType`, `reportUnknownMemberType`, `reportUnknownArgumentType` warnings
  - Reports unused variables as informational (not errors)

### yaml — YAML LSP with Multi-Schema Support
- **Repository:** [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- **Purpose:** YAML language server (yamlls) with schema validation for multiple file types.
- **Supported Schemas:**
  | Schema | File Pattern |
  |--------|-------------|
  | Kubernetes | Dynamic (from kubernetes.nvim) |
  | GitHub Actions Workflow | `.github/workflows/*` |
  | GitHub Action | `.github/action.{yml,yaml}` |
  | GitLab CI | `*gitlab-ci*.{yml,yaml}` |
  | OpenAPI v3.1 | `*api*.{yml,yaml}` |
  | Docker Compose | `*docker-compose*.{yml,yaml}` |
  | Argo Workflows | `*flow*.{yml,yaml}` |
  | Kustomization | `kustomization.{yml,yaml}` |

---

## LazyVim Extras

These are built-in extras from the [LazyVim](https://github.com/LazyVim/LazyVim) project, enabled in `lazyvim.json`:

| Extra | Purpose |
|-------|---------|
| `coding.luasnip` | Lua Snippet engine for expandable code snippets |
| `dap.core` | Debug Adapter Protocol — integrated debugger support |
| `dap.nlua` | Lua-specific DAP integration |
| `lang.docker` | Dockerfile syntax highlighting and linting |
| `lang.go` | Go language support (gopls, goimports) |
| `lang.helm` | Helm chart syntax and linting |
| `lang.json` | JSON schema validation and formatting |
| `lang.markdown` | Markdown preview and linting |
| `lang.python` | Python language support (black, flake8) |
| `lang.terraform` | Terraform HCL syntax and terraform-ls |
| `lang.toml` | TOML syntax and schema validation |
| `lang.typescript` | TypeScript/JavaScript support (tsserver) |
| `lang.yaml` | YAML syntax and validation |

---

## External Language Servers (Not Plugins)

These must be installed separately via your package manager or pip:

| Tool | Installation | Purpose |
|------|-------------|---------|
| `basedpyright` | `pip install basedpyright` | Python type checking |
| `gopls` | `go install golang.org/x/tools/gopls@latest` | Go language server |
| `helm-ls` | [helm-ls repo](https://github.com/mrjosh/helm-ls) | Helm language server |
| `yaml-language-server` | `npm install -g yaml-language-server` | YAML LSP |
| `terraform-ls` | [terraform-ls repo](https://github.com/hashicorp/terraform-ls) | Terraform language server |