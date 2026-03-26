#!/usr/bin/env bash
#
# run_once_before_09-code-directory.sh
# -------------------------------------
# Creates the ~/code directory structure.
#
# Repos are cloned via the `ghc` function in .zshrc:
#   ghc JudgeJules/my-repo
#   → clones to ~/code/github.com/JudgeJules/my-repo
#

echo ""
echo "→ [09] Code directory setup"

mkdir -p "$HOME/code/github.com"
echo "  ✓ Created ~/code/github.com/"
echo "  Use 'ghc owner/repo' to clone repos into the right place"
echo ""
