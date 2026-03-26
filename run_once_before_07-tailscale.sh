#!/usr/bin/env bash
#
# run_once_before_07-tailscale.sh
# ---------------------------------
# Authenticates this machine to your Tailnet using an auth key from 1Password.
#
# Auth key lives at: op://Personal/Tailscale Auth Key/credential
# Set it up at: https://login.tailscale.com/admin/settings/keys
# Recommended key settings:
#   - Reusable: yes (so the same key works on future machines)
#   - Pre-authorized: yes (no approval needed in admin console)
#   - Expiry: 90 days or no expiry (your preference)
#   - Tags: optional, useful if you use ACLs
#
# chezmoi runs this exactly once (tracked by hash).
# To re-run: `chezmoi apply --force`
#

echo ""
echo "→ [07] Tailscale"

# Check if already connected
if tailscale status &>/dev/null; then
  echo "  ✓ Tailscale already connected — skipping auth"
  exit 0
fi

# Check if tailscale binary is available
if ! command -v tailscale &>/dev/null; then
  echo "  ⚠ tailscale not found — is Tailscale installed?"
  echo "    Install with: brew install --cask tailscale"
  exit 1
fi

# Pull auth key from 1Password
echo "  Fetching auth key from 1Password..."
AUTH_KEY=$(op read "op://Personal/Tailscale Auth Key/credential" 2>/dev/null)

if [ -z "$AUTH_KEY" ]; then
  echo "  ✗ Could not read auth key from 1Password"
  echo "    Make sure you are signed in to the 1Password CLI: op signin"
  exit 1
fi

# Connect to Tailnet
# --authkey        non-interactive auth using the key from 1Password
# --accept-routes  accept subnet routes advertised by other devices on your Tailnet
# --accept-dns     use Tailscale's MagicDNS (reach devices by name, e.g. my-mac.tail...)
# --ssh            enable Tailscale SSH into this machine from other Tailnet devices
echo "  Connecting to Tailnet..."
tailscale up \
  --authkey="$AUTH_KEY" \
  --accept-routes \
  --accept-dns \
  --ssh

echo "  ✓ Tailscale connected"
echo "  Run 'tailscale status' to see your Tailnet"
echo "  Run 'tailscale ip' to see this machine's Tailscale IP"
echo ""
