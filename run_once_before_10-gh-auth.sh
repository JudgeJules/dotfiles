#!/usr/bin/env bash
#
# run_once_before_10-gh-auth.sh
# ------------------------------
# Authenticates the GitHub CLI using a PAT stored in 1Password.
#
# Runs after:
#   03 — brew bundle (installs gh)
#   02 — 1Password CLI (required for op read)
#
# The token lives at: op://Personal/gh CLI - dotfiles/credential
# To rotate: update the token in 1Password and run `chezmoi apply --force`
#

echo ""
echo "→ [10] GitHub CLI auth"

# Skip if already authenticated
if gh auth status &>/dev/null; then
    echo "  ↩ gh already authenticated — skipping"
    echo ""
    exit 0
fi

# Pull token from 1Password and authenticate
TOKEN=$(op read "op://Personal/gh CLI - dotfiles/token" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "  ✗ Could not read token from 1Password"
    echo "    Make sure 'gh CLI - dotfiles' item exists in Personal vault"
    echo "    with a 'token' field containing the GitHub PAT"
    echo ""
    exit 1
fi

echo "$TOKEN" | gh auth login --with-token

if gh auth status &>/dev/null; then
    echo "  ✓ gh authenticated as $(gh api user --jq .login)"
else
    echo "  ✗ gh auth failed — check token scopes in 1Password"
fi

echo ""
