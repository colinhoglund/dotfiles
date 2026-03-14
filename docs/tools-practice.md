# Terminal Tools Practice Guide

A quick reference for building `eza`, `zoxide`, `fzf`, Telescope, and Neovim's
LSP into daily workflows. Each section shows the old way, the new way, and
exercises to build the habit.

---

## eza — better ls

eza is a drop-in `ls` replacement with git status, colors, and icons built in.

### Key flags
```zsh
eza                        # basic listing (replaces ls)
eza -la                    # long + hidden (replaces ll)
eza -la --git              # show git status per file (M=modified, N=new, D=deleted)
eza --tree                 # directory tree (replaces: find . -type d | head -20)
eza --tree --level=2       # tree limited to 2 levels deep
eza -la --sort=modified    # sort by modification time
```

### Aliases already set in .zshrc
```zsh
ls   → eza
ll   → eza -la --git
```

### Practice
1. Run `ll` in this repo — see which files are modified vs clean
2. Run `eza --tree --level=2` to get a quick layout of any unfamiliar project
3. After a week, notice you never need to reach for `ls` flags to get color/sorting

---

## zoxide — frecent directory jumping

Zoxide tracks directories you visit by frequency + recency. The more you use `cd`,
the smarter `z` gets. It starts empty and improves over time.

### Commands
```zsh
z dot          # jump to ~/dotfiles (after visiting it a few times)
z pro api      # jump to ~/code/projects/api — matches multiple words
z -            # go back to previous directory (like cd -)
zi             # interactive fuzzy picker of all frecent dirs
```

### Mental model
- `cd` / `..` / `...` = relative navigation (where am I now, go up/across)
- `z` = forward navigation to places you've been before (browser history for dirs)

### Building the habit
Replace `cd` with `z` for directories you navigate to frequently:

```zsh
# old
cd ~/dotfiles

# new (after zoxide has learned it)
z dotfiles
```

### Practice exercises
1. `cd` to 5 different projects normally today — zoxide is learning
2. Tomorrow, try `z <partial>` for each one
3. Try `zi` to browse your frecent dirs interactively with fzf

---

## fzf — interactive fuzzy finder

fzf takes any list as input, lets you fuzzy-search it, and outputs the selection.

### Built-in zsh shortcuts (zero config required)

| Shortcut | What it does |
|---|---|
| `Ctrl-R` | Fuzzy search command history — replaces prefix search |
| `Ctrl-T` | Fuzzy search files in current dir tree — pastes path into prompt |
| `Alt-C`  | Fuzzy cd into a subdirectory |

**Start here.** Use `Ctrl-R` for a week and you'll never go back.

### fzf as an interactive filter (the pipe pattern)

```zsh
# Pattern: <list producer> | fzf | <action>

# Interactive git branch checkout
git branch | fzf | xargs git checkout

# Interactive git log — pick a commit to inspect
git log --oneline | fzf | awk '{print $1}' | xargs git show

# Open a changed file in your editor
git diff --name-only | fzf | xargs $EDITOR

# Kill a process by fuzzy-searching running processes
ps aux | fzf | awk '{print $2}' | xargs kill
```

The pattern is always:
1. Produce a list
2. Pipe to fzf — pause for interactive selection
3. Pipe the selected item to an action

### Practice exercises
1. Press `Ctrl-R` right now and search for a command you ran last week
2. Type `nvim ` then press `Ctrl-T` to fuzzy-pick a file without typing the path
3. In a repo with multiple branches: `git branch | fzf | xargs git checkout`

---

## Telescope — fuzzy finder inside Neovim

Telescope replaces CtrlP with a much richer interface: a live fuzzy search on the
left, a file preview pane on the right. It also surfaces LSP and git data.

Leader key is `<Space>`.

### File and text search

| Keymap | Description |
|---|---|
| `<leader>ff` | Find files in project |
| `<leader>fg` | Live grep — search text across all files (requires ripgrep) |
| `<leader>fz` | Fuzzy find within the current buffer |
| `<leader>fo` | Recent files (files you've opened before) |
| `<leader>fb` | Switch between open buffers |

### LSP pickers (these need an LSP server attached)

| Keymap | Description |
|---|---|
| `<leader>fd` | All diagnostics (errors/warnings) in the project |
| `<leader>fr` | All references to the symbol under cursor |
| `<leader>fs` | All symbols (functions, types, vars) in current file |

### Git pickers

| Keymap | Description |
|---|---|
| `<leader>fc` | Git commit history — fuzzy search commits, preview diffs |
| `<leader>fgb` | Git branches — pick one to checkout |

### Inside any Telescope window

| Key | Action |
|---|---|
| Type anything | Narrow results |
| `<CR>` | Open selection |
| `<C-v>` | Open in vertical split |
| `<C-x>` | Open in horizontal split |
| `<C-t>` | Open in new tab |
| `<Esc>` | Close |

### Practice exercises
1. Open any project with `nvim .`, then `<leader>fg` and search for a function name
2. Put your cursor on a Go/Python function call, press `<leader>fr` to see all call sites
3. Use `<leader>fc` to browse git history and preview what changed in each commit

---

## Neovim LSP — language intelligence

LSP servers are auto-installed by Mason on first launch. These keymaps are active
whenever an LSP server is attached to the current buffer.

### Navigation

| Keymap | Description |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to all references (opens in Telescope) |
| `K` | Hover documentation for symbol under cursor |
| `<leader>D` | Go to type definition |

### Editing

| Keymap | Description |
|---|---|
| `<leader>rn` | Rename symbol (renames across all files) |
| `<leader>ca` | Code action (imports, quick fixes, refactors) |

### Diagnostics navigation
```
]d     next diagnostic (error/warning)
[d     previous diagnostic
```

### Practice exercises
1. Open a `.go` file, hover over a type with `K` — you get the full signature and docs
2. Rename a function with `<leader>rn` — it updates every file that uses it
3. On an unused import, `<leader>ca` will offer to remove it

---

## Neovim — plugin management (lazy.nvim)

lazy.nvim lazy-loads plugins so startup stays fast regardless of how many you add.

```
:Lazy          open plugin manager UI
:Lazy update   update all plugins
:Lazy install  install any new plugins added to init.lua
:Lazy sync     install + update + clean in one shot
```

---

## Neovim — LSP server management (Mason)

Mason installs LSP servers, linters, and formatters into `~/.local/share/nvim/mason/`.

```
:Mason                    open Mason UI (shows installed/available servers)
:MasonInstall <server>    install a specific server
:MasonUninstall <server>  remove a server
```

Configured servers (auto-installed): `gopls`, `pyright`, `terraformls`, `lua_ls`

---

## Neovim — git workflow (gitsigns + fugitive)

### Gitsigns (gutter indicators + hunk operations)

| Keymap | Description |
|---|---|
| `]c` | Jump to next changed hunk |
| `[c` | Jump to previous changed hunk |
| `<leader>hp` | Preview hunk diff inline |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk to HEAD |
| `<leader>hb` | Inline git blame for current line |

### vim-fugitive (git commands from inside Neovim)

```
:Git status     full git status (interactive, press = to toggle diff)
:Git diff       diff current file
:Git log        log with diff preview
:Git blame      open blame view (q to close)
:Git commit     open commit message editor
:Git push
:Git pull
```

---

## How the tools work together

```zsh
# Jump to a project and open a file immediately
z myproject && nvim $(fzf)

# From inside nvim: search all files for a pattern with preview
<leader>fg

# Browse recent dirs interactively, then grep inside nvim
zi            # pick a dir via fzf
<leader>fg    # grep across it

# Review all errors in the project before committing
<leader>fd    # telescope diagnostics picker
```

---

## Suggested adoption order

1. **Day 1:** Use `Ctrl-R` for history — immediate payoff, zero learning curve
2. **Day 1:** Notice `ll` now shows git status — nothing to memorize
3. **Week 1:** Replace `cd <long-path>` with `z <partial>` for frequent dirs
4. **Week 1:** Use `<leader>ff` and `<leader>fg` in Neovim instead of CtrlP
5. **Week 2:** Use `gd`, `K`, `gr` for code navigation instead of grep-ing
6. **Week 2:** Use `<leader>fc` to review git history without leaving Neovim
7. **Ongoing:** `zi` becomes your primary way to hop between projects
