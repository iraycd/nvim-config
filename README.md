# Neovim Config

Personal Neovim configuration with an IDE-like setup. Optimized for multi-repo projects.

## Prerequisites

```bash
brew install neovim fd ripgrep lazygit
brew install --cask font-hack-nerd-font
```

Set your terminal font to **Hack Nerd Font** or **Hack Nerd Font Mono**.

## Installation

```bash
git clone git@github.com:iraycd/nvim-config.git ~/.config/nvim
```

Open `nvim` and plugins will auto-install on first launch.

## Plugins

| Plugin | Purpose |
|--------|---------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) | File explorer |
| [telescope](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [telescope-fzf-native](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | Native fzf sorter |
| [gitsigns](https://github.com/lewis6991/gitsigns.nvim) | Git gutter signs |
| [lazygit](https://github.com/kdheepak/lazygit.nvim) | Git UI |
| [diffview](https://github.com/sindrets/diffview.nvim) | Git diff/history viewer |
| [bufferline](https://github.com/akinsho/bufferline.nvim) | Tab-like buffer bar |
| [catppuccin](https://github.com/catppuccin/nvim) | Dark theme (mocha) |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File type icons |
| multi-repo-git (custom) | Git status labels for nested repos |

## Keyboard Shortcuts

Leader key is `Space`.

### File Tree

| Shortcut | Action |
|----------|--------|
| `Space + e` | Toggle file tree |

**Inside the file tree:**

| Shortcut | Action |
|----------|--------|
| `j` / `k` | Move up/down |
| `Enter` / `o` | Open file / expand folder |
| `Tab` | Preview file |
| `a` | Create file/directory (end with `/` for dir) |
| `d` | Delete |
| `r` | Rename |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste |
| `Backspace` | Go to parent directory |
| `-` | Navigate up one directory |
| `gl` | Open lazygit for the repo under cursor |
| `g?` | Show all keybinds |

### File Search

| Shortcut | Action |
|----------|--------|
| `Space + p` | Find files (fuzzy, any order like Ctrl+P) |
| `Space + f` | Search text in files (like Ctrl+Shift+F) |
| `Space + b` | Switch between open buffers |

### Tabs / Buffers

| Shortcut | Action |
|----------|--------|
| `Tab` | Next tab |
| `Shift + Tab` | Previous tab |
| `Space + x` | Close current tab |

### Window Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl+w h` | Jump to left window (tree) |
| `Ctrl+w l` | Jump to right window (editor) |
| `Ctrl+w w` | Cycle between windows |

### Git - LazyGit

| Shortcut | Action |
|----------|--------|
| `Space + g g` | Open lazygit (auto-detects repo, or lets you pick) |

Press `q` to close lazygit, then `:bd` to close the buffer.

### Git - Gitsigns (inline changes)

| Shortcut | Action |
|----------|--------|
| `]c` | Next changed hunk |
| `[c` | Previous changed hunk |
| `Space + g p` | Preview hunk inline |
| `Space + g a` | Stage hunk |
| `Space + g u` | Unstage hunk |
| `Space + g r` | Reset hunk |
| `Space + g A` | Stage entire file |
| `Space + g R` | Reset entire file |
| `Space + g b` | Blame current line |
| `Space + g B` | Blame line (full commit message) |
| `Space + g d` | Diff against index |

### Git - Diffview (history)

| Shortcut | Action |
|----------|--------|
| `Space + g h` | Current file commit history |
| `Space + g H` | Full repo commit history |
| `Space + g o` | View all uncommitted changes side-by-side |
| `Space + g c` | Close diff view |

### Git - Multi-repo Status

| Shortcut | Action |
|----------|--------|
| `Space + g m` | Manually refresh repo status labels |

Repo status labels auto-refresh every 5 seconds and on file save.

### File Navigation

| Shortcut | Action |
|----------|--------|
| `gg` | Go to top of file |
| `G` | Go to bottom of file |
| `Ctrl + f` | Page down |
| `Ctrl + b` | Page up |
| `Ctrl + d` | Half page down |
| `Ctrl + u` | Half page up |
| `0` | Beginning of line |
| `$` | End of line |
| `w` | Next word |
| `b` | Previous word |
| `{` | Previous blank line |
| `}` | Next blank line |
| `:42` | Go to line 42 |
