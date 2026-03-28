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
- **dot_zshrc** — full shell config with PATH, fnm, uv, Starship, fzf, zoxide, bat, eza, aliases, functions, docker drift check hook ✅
- **Brewfile** — all CLI tools, apps, fonts managed via brew bundle ✅
- **run_once scripts** — all ten in place ✅
  - `run_once_before_01-install-homebrew.sh`
  - `run_once_before_02-install-1password-cli.sh`
  - `run_once_before_03-install-packages.sh`
  - `run_once_before_04-install-fonts.sh`
  - `run_once_before_05-macos-defaults.sh`
  - `run_once_before_06-editor-settings.sh`
  - `run_once_before_07-tailscale.sh`
  - `run_once_before_08-docker-setup.sh`
  - `run_once_before_09-code-directory.sh`
  - `run_once_before_10-gh-auth.sh`
- **Code directory structure** — `~/code/github.com/<owner>/<repo>` mirrors GitHub URL structure ✅
- **gh repo clone routing** — `gh repo clone owner/repo` always lands in `~/code/github.com/owner/repo` via gh wrapper in .zshrc ✅
- **gh CLI auth** — `run_once_before_10-gh-auth.sh` authenticates via PAT stored in 1Password (`op://Personal/gh CLI - dotfiles/token`) ✅
- **macOS defaults script** — comprehensive Tahoe edition from jordan-rs/dotfiles-v2 ✅
- **Starship prompt config** — `dot_config/starship.toml` ✅
- **`.gitignore_global`** — global ignores for macOS, secrets, editors, languages, build artifacts ✅
- **`.editorconfig`** — universal coding contract (indent, charset, line endings, per-language overrides) ✅
- **Editor settings adapter** — `run_once_before_06-editor-settings.sh` writes settings.json for VS Code/Cursor and Sublime Text; JetBrains reads `.editorconfig` natively ✅
- **Pre-commit secret scanning** — global gitleaks hook via `core.hooksPath`; scans staged files on every commit in every repo ✅
- **Tailscale** — `run_once_before_07-tailscale.sh` connects via auth key pulled from 1Password ✅
- **LLM Docker stack** — fully working ✅
  - Open WebUI at http://localhost:3000 (auth enabled)
  - mitmproxy at http://localhost:8081 (egress proxy + traffic inspector)
  - Ollama running natively as Ollama.app (Metal GPU, not in Docker)
  - docker/compose.yml, docker/.env.example, docker/README.md, docker/.gitignore all committed
  - Kill switch: `docker network disconnect llm-egress mitmproxy`
  - `_docker_drift_check` precmd hook in .zshrc warns when ~/docker files differ from chezmoi source
  - Architecture decision log in docker/README.md documents all tradeoffs

- **Global `~/.claude/CLAUDE.md`** — personal Claude rules deployed via chezmoi ✅
  - General behavior (ask before assuming intent)
  - DOING/EXPECT/IF protocol for significant actions
  - Traffic light autonomy levels (🟢🟡🔴)
  - Code standards (explicit errors, no unsolicited fallbacks, no --no-verify)
  - Blocked state protocol
- **`~/code/github.com/` directory structure** — mirrors GitHub URL structure ✅
- **`gh repo clone` routing** — wrapper in .zshrc enforces correct landing directory ✅
- **gh CLI auth** — automated via 1Password PAT in `run_once_before_10-gh-auth.sh` ✅

### mac-file-automation (machine/jordans-mbp branch):
- Screenshot renamer daemon running via launchd ✅
- Two-path pipeline: OCR (ocrmac) → gemma3:latest for text, qwen3-vl:8b for image-only ✅
- Vision path confirmed working on real image-only screenshots ✅
- Dynamic plist generation — no hardcoded paths ✅
- `scripts/compare_models.py` for benchmarking models against real screenshots ✅
- Model learnings documented in CLAUDE.md
- Logs at: `~/code/github.com/JudgeJules/mac-file-automation/logs/screenshot_renamer.err`
- **Finder defaults**: column view set via macOS defaults script; Date Added sort requires manual "Use as Defaults" in Finder (per-folder, not enforceable via defaults write)
- **Model output cleanup**: both naming_client.py and ollama_client.py now sanitize descriptions to kebab-case before validation rather than rejecting outright — reduces fallback rate
- **Key learnings added to CLAUDE.md**:
  - qwen3-vl:8b does not support structured output (format schema silences it) — use plain-text prompt, parse description directly
  - naming_client.py now cleans model output to kebab-case before validation

### Known issues / still to do:
- **Raycast** needs Cmd+Space set manually as its hotkey (System Settings → Keyboard → Shortcuts → Spotlight → uncheck, then set in Raycast prefs)
- **Kiro (AWS AI IDE)** — not on Homebrew, install manually from https://kiro.dev
- **mitmproxy SSL interception** — Open WebUI gets `SSLCertVerificationError` when reaching external HTTPS APIs (e.g. OpenAI) through mitmproxy. mitmproxy CA cert not trusted inside the container. Does not affect Ollama (local). Options if needed: bake mitmproxy CA into open-webui image, or add `PYTHONHTTPSVERIFY=0` env (insecure). Currently: cloud APIs work when added directly in Open WebUI settings (bypasses cert issue for API calls made by the UI layer).
- **Little Snitch** — installed via Brewfile but requires manual activation and rule setup post-install

### Ollama status:
- Installed as **cask** (`brew install --cask ollama`) — Ollama.app 0.18.2
- The formula version caused a Metal crash on macOS 26 Tahoe (`ggml_metal_library_init` failure, MPPTensorOpsMatMul2dImpl.h static_assert). The cask (app bundle) resolves it.
- Models currently pulled: `gemma3:latest` (4.3B Q4_K_M), `qwen3.5:latest` (9.7B Q4_K_M)
- Pull more from Open WebUI: Settings → Models → search + download

### Architecture decisions made:
- **chezmoi** for dotfile management
- **1Password** as single identity/secrets layer — chezmoi templates pull secrets at apply time via `op://` references
- Repo is **public** because secrets never land in it
- Bootstrap script is minimal — only installs Xcode CLI tools + chezmoi
- run_once scripts handle all heavy setup inside the repo
- **Ollama on host** (not Docker) — required for Metal GPU; Little Snitch monitors its network traffic
- **mitmproxy** as container egress proxy — all Open WebUI internet traffic logged + kill-switchable
- **llm-internal network** (`internal: true`) — no direct internet for Open WebUI
- **host-access network** — workaround for Docker Desktop macOS port-forwarding limitation with internal-only networks
- **extra_hosts: host-gateway** — enables `host.docker.internal` resolution inside the internal network
- **Docker Model Runner / vllm-metal** deferred — only ~200 models (vs 45K GGUF), 1 month old, no native Open WebUI support; re-evaluate 2027
- **~/docker** intentionally NOT chezmoi-managed — allows local iteration; drift check in .zshrc catches uncommitted changes

### LLM stack quick reference:
```bash
# Start stack
cd ~/docker && docker compose up -d

# Stop stack
docker compose down

# Kill switch (cut container internet)
docker network disconnect llm-egress mitmproxy

# Restore
docker network connect llm-egress mitmproxy

# View egress traffic
open http://localhost:8081

# Access Open WebUI
open http://localhost:3000

# Check Ollama models
curl http://localhost:11434/api/tags
```

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
### Machine: MacBook Pro, Apple Silicon, macOS 26 Tahoe, fresh setup
### Git email: 3988877+JudgeJules@users.noreply.github.com
