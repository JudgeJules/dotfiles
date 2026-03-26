# Brewfile
# ---------
# Managed by chezmoi. Installed by run_once_before_03-install-packages.sh
#
# To add something:    add a line here, commit, then run `chezmoi apply`
# To remove something: delete the line, commit, then run `brew bundle cleanup --force`
# To check status:     run `brew bundle check --file=~/.local/share/chezmoi/Brewfile`
#

# ──────────────────────────────────────────────
# Core CLI
# ──────────────────────────────────────────────
brew "git"          # Homebrew's git is newer than the Xcode CLI version
brew "gitleaks"     # Secret scanning — blocks commits containing API keys, tokens, passwords
brew "gh"           # GitHub CLI — create PRs, view issues, manage repos from terminal
brew "chezmoi"      # Dotfile manager (initially installed via bootstrap, now Homebrew-managed)
brew "starship"     # Shell prompt (configured in ~/.config/starship.toml)

# ──────────────────────────────────────────────
# Shell Enhancements
# ──────────────────────────────────────────────
brew "fzf"          # Fuzzy finder — Ctrl+R for history, Ctrl+T for files, Alt+C for dirs
                    # Single highest-ROI shell tool. Used by zoxide, gbco, fkill functions
brew "zoxide"       # Smarter cd — learns your frecent dirs. `cd proj` finds it automatically
brew "bat"          # Better cat — syntax highlighting, line numbers, git diff markers
brew "eza"          # Better ls — colors, icons, git status in file listings
brew "fd"           # Better find — used by fzf for file search, respects .gitignore

# ──────────────────────────────────────────────
# Node
# ──────────────────────────────────────────────
brew "fnm"          # Fast Node version manager (written in Rust, reads .nvmrc files)
                    # Usage: fnm install --lts && fnm use lts-latest

# ──────────────────────────────────────────────
# Python
# ──────────────────────────────────────────────
brew "uv"           # All-in-one Python version manager + package manager
                    # Replaces: pyenv + pip + venv + pip-tools
                    # Usage: uv python install 3.12 && uv venv && uv pip install <pkg>

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────
cask "tailscale"    # Mesh VPN — access work resources without a corporate VPN

# ──────────────────────────────────────────────
# Terminals
# ──────────────────────────────────────────────
cask "iterm2"       # Current terminal (feature-rich, well-known)
cask "ghostty"      # Terminal to learn — fast, native, GPU-accelerated

# ──────────────────────────────────────────────
# Editors
# ──────────────────────────────────────────────
cask "visual-studio-code"   # Primary editor
cask "sublime-text"         # Fast secondary editor — great for quick file edits
cask "jetbrains-toolbox"    # Installs/updates any JetBrains IDE from one place
                            # Note: Kiro (AWS AI IDE) not yet on Homebrew — install manually

# ──────────────────────────────────────────────
# Dev Tools
# ──────────────────────────────────────────────
cask "docker"       # Docker Desktop — containers, compose, Docker daemon
cask "ollama"       # Local LLM runtime — runs models on Metal GPU (host, not Docker)

# ──────────────────────────────────────────────
# Productivity
# ──────────────────────────────────────────────
cask "raycast"      # Spotlight replacement — launcher, clipboard history, window snapping

# ──────────────────────────────────────────────
# Security
# ──────────────────────────────────────────────
cask "1password-cli"  # Already installed by script 02 — listed here so bundle tracks it
cask "little-snitch"  # Host-level network monitor — covers what mitmproxy misses (native processes, model runtimes running on host)
