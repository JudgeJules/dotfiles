# Brewfile
# ---------
# Managed by chezmoi. Installed by run_once_before_03-install-packages.sh
#
# To add something:   add a line here, commit, then run `chezmoi apply`
# To remove something: delete the line, commit, then run `brew bundle cleanup`
# To check status:    run `brew bundle check --file=~/.local/share/chezmoi/Brewfile`
#

# ──────────────────────────────────────────────
# Core CLI
# ──────────────────────────────────────────────
brew "git"          # Homebrew's git is newer than the Xcode CLI version
brew "gh"           # GitHub CLI — create PRs, view issues, manage repos from terminal
brew "chezmoi"      # Dotfile manager (initially installed via bootstrap, now Homebrew-managed)
brew "starship"     # Shell prompt (configured separately in .zshrc)

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

# ──────────────────────────────────────────────
# AI / LLMs
# ──────────────────────────────────────────────
cask "ollama"       # Run local LLMs (Llama, Mistral, etc.) — sandboxed in Docker later

# ──────────────────────────────────────────────
# Productivity
# ──────────────────────────────────────────────
cask "raycast"      # Spotlight replacement — launcher, clipboard history, window snapping
                    # Replaces Rectangle for window management if you use Raycast's built-in

# ──────────────────────────────────────────────
# Security
# ──────────────────────────────────────────────
cask "1password-cli"  # Already installed by script 02 — listed here so bundle tracks it
