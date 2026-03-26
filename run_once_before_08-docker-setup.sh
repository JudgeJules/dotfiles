#!/usr/bin/env bash
#
# run_once_before_08-docker-setup.sh
# ------------------------------------
# Sets up ~/docker with the LLM infrastructure files from chezmoi source.
#
# ~/docker is intentionally NOT managed directly by chezmoi — you may edit
# compose.yml locally while iterating, and the drift check in .zshrc will
# remind you to commit changes back.
#
# chezmoi runs this exactly once (tracked by hash).
# To re-run after changes: `chezmoi apply --force`
#

echo ""
echo "→ [08] Docker setup"

DOCKER_DIR="$HOME/docker"
CHEZMOI_SRC="$HOME/.local/share/chezmoi/docker"

mkdir -p "$DOCKER_DIR"

# Copy files from chezmoi source — only if they don't already exist locally
# (avoids overwriting local edits on re-runs triggered by other script changes)
for f in compose.yml README.md .env.example .gitignore; do
    if [ ! -f "$DOCKER_DIR/$f" ]; then
        cp "$CHEZMOI_SRC/$f" "$DOCKER_DIR/$f"
        echo "  ✓ Created ~/docker/$f"
    else
        echo "  ↩ ~/docker/$f already exists — skipping"
    fi
done

echo ""
echo "  Next steps:"
echo "    1. brew services start ollama"
echo "    2. cd ~/docker && cp .env.example .env"
echo "    3. Fill in WEBUI_SECRET_KEY in .env (generate: openssl rand -hex 32)"
echo "    4. docker compose up -d"
echo "    5. open http://localhost:3000"
echo ""
