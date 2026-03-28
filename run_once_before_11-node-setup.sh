#!/usr/bin/env bash
# run_once_before_11-node-setup.sh
# ---------------------------------
# Installs Node LTS via fnm and sets it as the default.
#
# Why not in Brewfile: fnm installs Node versions, it doesn't ship one.
# Why eval "$(fnm env)": run_once scripts are non-interactive bash — the
# shell hooks from .zshrc aren't loaded, so fnm must be bootstrapped manually.

set -euo pipefail

echo "==> Setting up Node via fnm..."

# Bootstrap fnm environment (mirrors what .zshrc does in interactive shells)
eval "$(fnm env)"

# Install latest LTS — fnm reads .nvmrc / .node-version per project automatically
fnm install --lts
fnm default lts-latest

echo "==> Node $(node --version) installed and set as default"
echo "==> npm $(npm --version)"
