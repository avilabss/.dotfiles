# Neovim setup

This repository installs the latest stable Neovim, stows its configuration to
`~/.config/nvim`, and provides an IDE-like setup without hiding the underlying
Neovim workflows. New users should install it, open `nvim` once to fetch the
locked plugins, and then start with the keymap cheat sheet.

## Find what you need

| Goal | Go to |
|---|---|
| Install or update Neovim | [Install and update Neovim](#install-and-update-neovim) |
| Learn everyday navigation and editing keys | [Cheat sheet](#cheat-sheet) |
| Check language support and prerequisites | [Language workflows](#language-workflows) |
| Understand plugin and session behavior | [Configuration and plugins](#configuration-and-plugins) and [Automatic behavior](#automatic-behavior) |
| Diagnose a missing tool, mapping, or formatter | [Management and troubleshooting](#management-and-troubleshooting) |

## Install and update Neovim

Neovim is part of the default bootstrap:

```bash
./bootstrap.sh
```

To rerun only its installation role (plus the always-run common role), use:

```bash
./bootstrap.sh --tags nvim
```

- **Linux:** Ansible resolves GitHub's latest non-prerelease Neovim release and
  installs its official x86-64 or ARM64 tarball under `/opt/nvim`, with
  `/usr/local/bin/nvim` as the entry point. A rerun upgrades an older install.
- **macOS:** Ansible updates Homebrew metadata and keeps the `neovim` formula at
  its latest version.

This latest-stable policy applies to Neovim itself, not to plugins.

## Configuration and plugins

The configuration lives under [`nvim/.config/nvim/`](../nvim/.config/nvim/):

- `init.lua` loads editor options and lazy.nvim.
- `lua/config/` contains base options and lazy.nvim bootstrap code.
- `lua/plugins/` contains one focused specification per feature.
- `lazy-lock.json` is committed and pins plugin revisions for reproducible
  installs.

On first launch, run `nvim` with Git and network access available. lazy.nvim
then bootstraps itself and installs the locked plugins. Its update checker
reports available updates but does not install them. Use `:Lazy update` when
intentionally updating plugins, review the resulting lockfile, and commit it.
After pulling a changed lockfile, `:Lazy restore` returns installed plugins to
those revisions.

The interface uses **Catppuccin Mocha**, with lualine, indentation guides,
icons, and which-key. The main functionality groups are:

- **Editing:** nvim-cmp, LuaSnip, nvim-autopairs, native Neovim commenting, and
  vim-sleuth indentation detection.
- **Languages:** native LSP configured through nvim-lspconfig, Mason-managed
  servers and tools, Conform formatting, and Treesitter textobjects.
- **Projects:** Telescope, Neo-tree, Gitsigns, Fugitive, automatic sessions,
  Toggleterm, and nvim-dap with its UI and virtual text.

## Automatic behavior

- Mason installs the configured LSP servers, including Pyright and Ruff,
  rust-analyzer, gopls, ts_ls, ESLint, html, cssls, jsonls, and Svelte. It also
  requests Prettier, Ruff, goimports, and `tree-sitter-cli`; the DAP integration
  requests debugpy, codelldb, Delve, and the JavaScript adapter.
- Completion combines LSP, snippet, path, and buffer suggestions. Autopairs
  loads on first entering Insert mode and integrates with completion.
- Conform formats on save with Prettier for configured web/data filetypes and
  Ruff for Python, falling back to an attached LSP when no configured formatter
  is available.
- Sessions save on exit and restore on entry by project. Automatic sessions are
  suppressed for the home, Downloads, Documents, and `/tmp` directories.
- Gitsigns marks changed lines. DAP opens its UI when debugging starts and
  closes it when the session terminates or exits.
- which-key shows named leader groups after a short pause.

## Language workflows

Conform formats supported files before saving and `:Format` runs it manually.
Its configured external formatter takes priority; an attached LSP is the
fallback when that formatter is unavailable.

| Language | LSP | Formatting | Diagnostics / linting | Debugging |
|---|---|---|---|---|
| Python | Pyright + Ruff | Ruff import organization, then Ruff formatting | Pyright types + Ruff diagnostics | debugpy: launch current file |
| Rust | rust-analyzer | rustfmt | rust-analyzer runs Clippy checks | codelldb: launch an executable |
| Go | gopls | goimports | gopls with staticcheck enabled | Delve: package, arguments, file test, or `go.mod` package test |
| HTML | html | Prettier | html | — |
| CSS / SCSS | cssls | Prettier | cssls | — |
| JSON / JSONC | jsonls with schema support | Prettier for JSON; jsonls fallback for JSONC | jsonls | — |
| JavaScript / TypeScript / React | ts_ls + project-aware ESLint | Prettier | ts_ls + ESLint when configured in the project | Node launch/attach; Chrome launch/attach |
| Svelte | svelte + project-aware ESLint | Project-local Prettier integration, otherwise svelte LSP fallback | svelte + ESLint when configured in the project | — |

### Language details and prerequisites

- **Python:** Pyright remains responsible for hover and type information. Ruff
  supplies diagnostics and code actions, organizes imports, and formats. When
  debugpy launches the current file, it chooses the first executable Python
  from an active `VIRTUAL_ENV` or `CONDA_PREFIX`, project-root `.venv`,
  project-root `venv`, `python3`, then `python`. If no project marker is found,
  the current working directory is used for the `.venv` and `venv` checks.
- **Rust:** rust-analyzer runs `clippy` for checks and Conform runs `rustfmt`.
  The codelldb launch choices prompt for the executable; one also prompts for
  arguments. Installing the adapter does not build the executable.
- **Go:** gopls has staticcheck analysis enabled, while goimports formats and
  organizes imports. Delve can launch the workspace package, prompt for
  arguments, debug the current test file, or test the current file's package
  in a `go.mod` project.
- **JavaScript, TypeScript, and React:** ts_ls supplies language features.
  ESLint attaches only when nvim-lspconfig finds a project ESLint
  configuration; the project must also provide a compatible ESLint library.
  These dotfiles do not add ESLint to projects.
- **JSON:** jsonls supplies diagnostics and schema-aware completion for JSON
  and JSONC. Prettier is configured directly for JSON; JSONC uses the attached
  LSP formatting fallback.
- **Web formatting:** Mason's Prettier handles JavaScript, TypeScript, React,
  HTML, CSS/SCSS, and JSON. Svelte deliberately uses it only when a project
  directory provides both `node_modules/.bin/prettier` and
  `node_modules/prettier-plugin-svelte`; otherwise formatting falls back to the
  attached svelte LSP. The dotfiles do not add those dependencies to projects.
- **JavaScript debugging:** the installed JavaScript adapter provides explicit
  Node choices to launch the current file or attach to a selected process, and
  Chrome choices to launch a prompted URL or attach to a prompted remote-debug
  port. Adapter installation alone does not supply a working application,
  browser debug port, project build, or source-map configuration.

On Linux, the default development packages include `build-essential` on
Debian/Ubuntu and `gcc`, `gcc-c++`, and `make` on Fedora. These provide the
compiler/build prerequisites commonly needed when Treesitter parsers or native
plugins must compile.

### Treesitter on first use

When a buffer's filetype has a supported parser, the configuration enables an
installed parser or starts installing the missing parser on demand. Highlighting
and indentation are enabled only when the parser and corresponding queries are
available. Textobjects likewise depend on language query support.

The locked nvim-treesitter `main` revision requires Neovim 0.12 or later and
`tree-sitter-cli` 0.26.1 or later installed outside npm. Mason is configured to
install the CLI from its official release assets; its package provided 0.26.11
when this lock was validated. Parser installation also needs network access,
`curl`, `tar`, and a working C compiler. Unsupported languages or missing
prerequisites stay on normal Neovim syntax/indentation. Check `:checkhealth
nvim-treesitter`, or run `:TSInstall <language>` after fixing a prerequisite.

## Cheat sheet

`<leader>` is **Space** and `<localleader>` is **backslash**. `<C-x>` means
Ctrl+x and `<M-x>` means Alt+x. Pause after Space to see the which-key menu.

Press `<leader>ch` in Normal mode to search described keymaps active in the
current context. The Telescope picker includes global mappings plus
buffer-local mappings currently provided by features such as LSP and Gitsigns,
across Normal, Insert, Visual, operator-pending, and Terminal modes. Type to
fuzzy-filter the results, press Enter to execute the selected mapping, or press
Escape twice from the initial Insert mode to close the picker. Lazy or
buffer-local mappings that are not active in the current buffer do not appear
here; the sections below remain the cross-context reference.

### Native commenting

Commenting uses the buffer's `commentstring` and Neovim's built-in mappings.

| Mode | Keys | Action |
|---|---|---|
| Normal | `gcc` | Toggle the current line, or `[count]` lines |
| Normal | `gc{motion}` | Toggle lines covered by a motion, such as `gcap` |
| Visual | `gc` | Toggle the selected lines |
| Operator-pending | `gc` | Select the surrounding contiguous comment block |

### Search and files

| Mode | Keys | Action |
|---|---|---|
| Normal | `<leader>ff` | Find files with Telescope |
| Normal | `<leader>fg` | Search project text with Telescope |
| Normal | `<leader>fb` | Find open buffers with Telescope |
| Normal | `<leader>fh` | Search Neovim help tags with Telescope |
| Normal | `<C-n>` | Toggle Neo-tree; dotfiles and gitignored files remain visible |

Telescope live grep uses `ripgrep`, which the bootstrap installs.

### LSP and diagnostics

These buffer-local mappings appear when an LSP attaches.

| Mode | Keys | Action |
|---|---|---|
| Normal | `<leader>ld` or `gd` | Go to definition |
| Normal | `<leader>lD` | Go to declaration |
| Normal | `<leader>lr` | List references |
| Normal | `<leader>li` | Go to implementation |
| Normal | `<leader>lt` | Go to type definition |
| Normal | `<leader>la` | Show code actions |
| Normal | `<leader>lR` | Rename symbol |
| Normal | `<leader>lh` or `K` | Show hover documentation |
| Normal | `<leader>ls` | Show signature help |
| Normal | `<leader>le` | Show line diagnostics in a float |
| Normal | `<leader>ln` or `]d` | Go to next diagnostic |
| Normal | `<leader>lp` or `[d` | Go to previous diagnostic |
| Normal | `<leader>lq` | Put diagnostics in the location list |
| Normal | `<leader>lf` | Format the buffer with `:Format` |

### Completion and snippets

These keys apply in Insert mode; Tab mappings also apply while selecting a
snippet placeholder.

| Keys | Action |
|---|---|
| `<C-Space>` | Open completion |
| `<C-n>` / `<C-p>` | Select next / previous completion item |
| `<Tab>` / `<S-Tab>` | Select next / previous item, or jump forward / backward through a snippet |
| `<C-b>` / `<C-f>` | Scroll completion documentation up / down |
| `<CR>` | Confirm the explicitly selected item; nothing is auto-selected |
| `<M-e>` | Start nvim-autopairs fast-wrap |

### Git: Gitsigns and Fugitive

Use Gitsigns for inline signs and buffer-local hunk navigation, blame,
staging/reset, and current-file diffs. Use Fugitive for repository-wide status
and index operations or native Vim diff splits.

The Gitsigns mappings through `ih` are buffer-local to attached files;
`<leader>gg` is the global Fugitive entry point.

| Mode | Keys | Action |
|---|---|---|
| Normal | `]c` / `[c` | Go to next / previous Git hunk |
| Normal | `<leader>gs` | Stage an unstaged hunk, or unstage it when already staged |
| Normal | `<leader>gr` | Reset the current hunk |
| Visual | `<leader>gs` / `<leader>gr` | Stage / reset the selected lines |
| Normal | `<leader>gS` | Stage the buffer |
| Normal | `<leader>gu` | The same stage/unstage action as `<leader>gs` |
| Normal | `<leader>gR` | Reset the buffer |
| Normal | `<leader>gp` | Preview the current hunk |
| Normal | `<leader>gb` | Show full blame for the current line |
| Normal | `<leader>gB` | Toggle current-line blame |
| Normal | `<leader>gd` | Diff against the index |
| Normal | `<leader>gD` | Diff against the previous revision (`~`) |
| Visual or operator-pending | `ih` | Select the current hunk |
| Normal | `<leader>gg` | Open Fugitive repository status with `:Git` |

In a Git-attached buffer, Gitsigns' buffer-local `[c` and `]c` take precedence
over the Treesitter class mappings below. In a diff window they retain native
diff navigation.

In the Fugitive status window, these are native Fugitive mappings from the
locked plugin revision:

| Keys | Action |
|---|---|
| `dv` | Diff the file under the cursor in a vertical split (`:Gvdiffsplit`) |
| `dd` | Diff the file under the cursor with `:Gdiffsplit` |
| `s` | Stage the file or hunk under the cursor |
| `u` | Unstage the file or hunk under the cursor |
| `-` | Toggle staging for the file or hunk under the cursor |
| `<CR>` | Open the file or Fugitive object under the cursor |
| `g?` | Show Fugitive mapping help |
| `gq` | Close the status window |

Useful Fugitive commands:

| Command | Use |
|---|---|
| `:Git` | Open repository status; with arguments, run that Git command |
| `:Gdiffsplit [object]` | Diff the current file against the index/work tree or supplied Git object; split direction follows available width |
| `:Gvdiffsplit [object]` | Open that file diff in a vertical split |
| `:Ghdiffsplit [object]` | Open that file diff in a horizontal split |
| `:Git difftool -y [args]` | Open every file changed by `git diff [args]` in a new tab with a Fugitive diff split |

For the all-file difftool flow, use native `gt` / `gT` (or `:tabnext` /
`:tabprevious`) to move through the generated tabs and `:tabclose` to close the
current one. Within a diff split, native Vim diff commands such as `]c`, `[c`,
`do`, and `dp` remain available.

### Treesitter textobjects

Selections work in Visual and operator-pending modes, so they can be combined
with operators (for example, `daf`). They require a parser and matching
textobject queries.

| Keys | Textobject |
|---|---|
| `af` / `if` | Outer / inner function |
| `ac` / `ic` | Outer / inner class |
| `aa` / `ia` | Outer / inner parameter |
| `ab` / `ib` | Outer / inner block |
| `al` / `il` | Outer / inner loop |
| `ai` / `ii` | Outer / inner conditional |

Structural navigation works in Normal, Visual, and operator-pending modes.

| Keys | Action |
|---|---|
| `]f` / `[f` | Next / previous function start |
| `]F` / `[F` | Next / previous function end |
| `]c` / `[c` | Next / previous class start |
| `]C` / `[C` | Next / previous class end |
| `]a` / `[a` | Next / previous parameter start |
| `]A` / `[A` | Next / previous parameter end |
| `<leader>na` / `<leader>pa` | Swap with next / previous argument |
| `<leader>nf` / `<leader>pf` | Swap with next / previous function |

### Sessions

| Mode | Keys | Action |
|---|---|---|
| Normal | `<leader>ss` | Save the current session |
| Normal | `<leader>sr` | Restore the current project's session |
| Normal | `<leader>sd` | Delete the current session |
| Normal | `<leader>sf` | Find sessions with the Telescope picker |

### Terminals

| Mode | Keys | Action |
|---|---|---|
| Normal, Insert, or terminal | `<C-\>` | Toggle the default floating terminal |
| Normal | `<leader>tf` | Open a floating terminal |
| Normal | `<leader>th` | Open a horizontal terminal |
| Normal | `<leader>tv` | Open a vertical terminal |
| Toggleterm terminal | `<Esc>` | Leave Terminal mode for Normal mode |
| Toggleterm terminal | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move to the window left/down/up/right |

### Debugging (DAP)

| Mode | Keys | Action |
|---|---|---|
| Normal | `<leader>db` | Toggle breakpoint |
| Normal | `<leader>dB` | Set a conditional breakpoint |
| Normal | `<leader>dc` | Start or continue debugging |
| Normal | `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out |
| Normal | `<leader>dr` | Open the DAP REPL |
| Normal | `<leader>dl` | Run the last debug configuration |
| Normal | `<leader>dt` | Terminate debugging |
| Normal | `<leader>du` | Toggle the DAP UI |
| Normal | `<leader>de` | Evaluate the expression under the cursor |
| Visual | `<leader>de` | Evaluate the selection |

Inside DAP UI panels, `<CR>` or double-click expands an item, `o` opens it, `d`
removes it, `e` edits it, `r` opens the REPL, and `t` toggles it. In floating DAP
windows, `q` or `<Esc>` closes the window.

## Management and troubleshooting

| Command | Use |
|---|---|
| `:Format` or `:'<,'>Format` | Format the buffer or selected range through Conform |
| `:ConformInfo` | Inspect selected formatters and their availability |
| `:Git` | Open Fugitive status or run a Git command |
| `:Lazy` | Inspect plugin status |
| `:Lazy update` | Intentionally update plugins and `lazy-lock.json` |
| `:Lazy restore` | Restore revisions recorded in `lazy-lock.json` |
| `:Mason` | Inspect installed language servers, formatters, and adapters |
| `:MasonToolsUpdate` | Update the configured Prettier, Ruff, goimports, and Treesitter CLI tools |
| `:TSInstall <language>` | Install one parser manually |
| `:TSUpdate [language]` | Update one parser, or all installed parsers when omitted |
| `:LspInfo` / `:checkhealth vim.lsp` | Inspect configured and attached LSP servers |
| `:checkhealth nvim-treesitter` | Check parser prerequisites and parser/query status |
| `:checkhealth mason` | Check Mason and external-tool prerequisites |
| `:checkhealth` | Run all available health checks |

If a mapping is missing, first confirm the relevant buffer-local feature is
active (LSP or Gitsigns), then use `:map <keys>` or `:verbose map <keys>` to see
what owns it. For plugin failures, open `:Lazy`; for formatting failures, start
with `:ConformInfo`.
