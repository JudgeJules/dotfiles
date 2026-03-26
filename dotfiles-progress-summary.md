# Dotfiles Setup — Progress Summary
## Carry this into the next chat

### What's done:
- **Bootstrap script (`bootstrap.sh`)** is written, uploaded to GitHub, and working
- Repo is at **github.com/JudgeJules/dotfiles** (public)
- **Xcode CLI tools** installed on the Mac
- **chezmoi** installed and initialized (binary at `/usr/local/bin/chezmoi`)
- Chezmoi source directory is at `~/.local/share/chezmoi/`
- **1Password desktop app** is installed, signed in, developer settings enabled (CLI integration + SSH agent + "Use Key Names")
- **1Password CLI** — installed via run_once script ✅
- **Homebrew** — installed via run_once script ✅
- **First git commit/push completed** — user has done add, commit, pull --rebase, reset --hard, and push
- **Git authenticates via SSH through 1Password agent** ✅ (no more HTTPS + PAT)
- **Git identity** configured via chezmoi template pulling from 1Password (`op://Personal/Git Identity/`) ✅
- **Git email** uses GitHub no-reply address (`3988877+JudgeJules@users.noreply.github.com`) ✅
- **SSH config** (`~/.ssh/config`) routes GitHub through 1Password agent socket ✅
- **dot_gitconfig.tmpl** — full git config with aliases, rebase, diff3, etc. ✅
- **dot_zshrc** — full shell config with PATH, fnm, uv, Starship, fzf, zoxide, bat, eza, aliases, functions ✅
- **Brewfile** — all CLI tools, apps, fonts managed via brew bundle ✅
- **run_once scripts** — all four in place and working ✅
  - `run_once_before_01-install-homebrew.sh`
  - `run_once_before_02-install-1password-cli.sh`
  - `run_once_before_03-install-packages.sh`
  - `run_once_before_04-install-fonts.sh`
  - `run_once_before_05-macos-defaults.sh` ✅
- **macOS defaults script** — comprehensive system configuration ✅ (updated to Tahoe edition from jordan-rs/dotfiles-v2)
- **Starship prompt config** — `dot_config/starship.toml` ✅
  - Two-line prompt, directory truncation, full git status, language versions (Node/Python/Rust/Go), Docker context, command duration, background jobs, system context (username/hostname shown only over SSH)
  - Dock: auto-hide, fast (0.1s), bottom, size 48, no recents, minimize to app icon
  - Finder: extensions, hidden files, path bar, status bar, list view, folders first, POSIX path in title
  - Keyboard: fast repeat (2), short delay (15), no autocorrect, no smart quotes/dashes, press-and-hold disabled, full keyboard access
  - Trackpad: tap to click, traditional scroll direction
  - Sound: muted startup chime, no volume feedback, no UI sounds
  - Screenshots: save to ~/Screenshots, PNG, no shadow
  - Display: screensaver after 30 minutes
  - Mac App Store: check every 14 days, auto-download, critical updates only
  - General: dark mode, quit keeps windows
  - Hot corners: top-right = Mission Control, bottom-right = Desktop
  - Security: LSQuarantine disabled (no "are you sure?" dialogs)
  - Bluetooth Audio: high quality AAC codec
  - iCloud: save new docs locally by default
  - Disk Utility: show all partitions and hidden volumes
  - Spotlight: disabled entirely (Raycast handles it), Cmd+Space freed up for Raycast
  - Time Machine: local backups disabled

### Known issues / still to do:
- **Raycast** needs Cmd+Space set manually as its hotkey (System Settings → Keyboard → Shortcuts → Spotlight → uncheck, then set in Raycast prefs)
- **`.gitignore_global`** — referenced in `dot_gitconfig.tmpl` but not created yet
- **Kiro (AWS AI IDE)** — not on Homebrew, install manually from https://kiro.dev
- **Docker network design** — llm-net, egress proxy, kill switches (not started)
- **LLM runtime registry** — Ollama first, designed for adding others (not started)
- **Editor adapter system** — `.editorconfig` as universal contract, per-editor adapter scripts (not started)
- **Pre-commit hooks** — secret scanning (not started)
- **Threat model** — still needs to be defined

### Build order — remaining:
5. **`.gitignore_global`** — global git ignore file
6. **Editor adapter system** — `.editorconfig` as universal contract, per-editor adapter scripts
7. **Docker network design** — llm-net, egress proxy, kill switches
8. **LLM runtime registry** — Ollama first, designed for adding others

### Architecture decisions made:
- **chezmoi** for dotfile management
- **1Password** as single identity/secrets layer — chezmoi templates pull secrets at apply time via `op://` references
- Repo is **public** because secrets never land in it
- Bootstrap script is minimal — only installs Xcode CLI tools + chezmoi
- chezmoi binary installs to `/usr/local/bin` via `-b` flag
- run_once scripts handle all heavy setup inside the repo

### Key requirements:
- Personal Mac, work tools accessed via web (no VPN)
- Local + remote LLMs, Docker-based sandboxing
- LLMs must NEVER touch host OS — sandboxing/isolation is critical
- Docker containers need internet access with kill switches
- Containers need to talk to each other
- Editor-agnostic setup — `.editorconfig` as the contract, adapter scripts per editor
- Git workflow: LLMs always work on `llm/*` branches, never touch main
- Pre-commit hooks for secret scanning
- **Observability** gap flagged but not addressed yet

### Git workflow:
```
chezmoi cd              # get into the repo
git status              # see what changed
git add .               # stage changes
git commit -m "message" # save snapshot
git push                # send to GitHub
```

### Git concepts encountered so far:
- `git status` / `git add` / `git commit` / `git push` — the basic cycle
- `git pull --rebase` — when remote has changes you don't have locally
- Merge conflicts — what they look like and how to abort with `git rebase --abort`
- `git reset --hard origin/main` — throw away local and match remote exactly
- `git push --force` — overwrite remote with local (use carefully, only on personal repos)
- `git commit --amend --author` — rewrite commit author metadata

### The user's GitHub username: JudgeJules
### Machine: MacBook Pro, Apple Silicon, macOS, fresh setup
### Git email: 3988877+JudgeJules@users.noreply.github.com