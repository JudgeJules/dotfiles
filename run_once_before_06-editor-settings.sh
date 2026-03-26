#!/usr/bin/env bash
#
# run_once_before_06-editor-settings.sh
# ----------------------------------------
# Writes settings.json for VS Code and Cursor.
#
# These apps live under ~/Library/Application Support/ which is awkward for
# chezmoi direct file management, so we write them here instead.
#
# Settings are aligned with ~/.editorconfig as the source of truth.
# EditorConfig wins for per-file formatting; these settings handle everything
# EditorConfig doesn't cover (UI, fonts, telemetry, extensions behavior, etc.).
#
# To re-run after changes: `chezmoi apply --force`
#

echo ""
echo "→ [06] Editor settings"

# ── Shared settings JSON ──────────────────────────────────────────────────────
# Both VS Code and Cursor get the same settings.

read -r -d '' SETTINGS_JSON << 'EOF'
{
  // ── EditorConfig alignment ──────────────────────────────────────────────
  // These mirror ~/.editorconfig. Setting them here too ensures they apply
  // even before the EditorConfig extension activates (e.g., new untitled files).
  "editor.detectIndentation": false,
  "editor.insertSpaces": true,
  "editor.tabSize": 2,
  "files.eol": "\n",
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true,
  "files.encoding": "utf8",

  // ── Format on save ────────────────────────────────────────────────────────
  "editor.formatOnSave": true,
  "editor.formatOnPaste": false,
  "editor.formatOnType": false,

  // ── Language-specific overrides (mirrors .editorconfig) ──────────────────
  "[python]": {
    "editor.tabSize": 4,
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "[go]": {
    "editor.tabSize": 4,
    "editor.insertSpaces": false,
    "editor.defaultFormatter": "golang.go"
  },
  "[rust]": {
    "editor.tabSize": 4,
    "editor.defaultFormatter": "rust-lang.rust-analyzer"
  },
  "[markdown]": {
    "files.trimTrailingWhitespace": false,
    "editor.wordWrap": "on",
    "editor.rulers": []
  },
  "[makefile]": {
    "editor.insertSpaces": false,
    "editor.tabSize": 4
  },

  // ── Font ──────────────────────────────────────────────────────────────────
  "editor.fontFamily": "'SF Mono', 'JetBrains Mono', Menlo, Monaco, monospace",
  "editor.fontSize": 13,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": true,
  "editor.letterSpacing": 0.3,
  "terminal.integrated.fontFamily": "'SF Mono', 'JetBrains Mono', Menlo, monospace",
  "terminal.integrated.fontSize": 13,

  // ── UI ────────────────────────────────────────────────────────────────────
  "editor.rulers": [88, 120],
  "editor.lineNumbers": "on",
  "editor.renderWhitespace": "boundary",
  "editor.minimap.enabled": false,
  "editor.scrollBeyondLastLine": false,
  "editor.smoothScrolling": true,
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.stickyScroll.enabled": true,
  "workbench.tree.indent": 16,
  "workbench.editor.tabSizing": "shrink",
  "workbench.editor.wrapTabs": true,

  // ── File explorer ─────────────────────────────────────────────────────────
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,
  "explorer.sortOrder": "filesFirst",

  // ── Git ───────────────────────────────────────────────────────────────────
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "diffEditor.ignoreTrimWhitespace": false,

  // ── Terminal ──────────────────────────────────────────────────────────────
  "terminal.integrated.shell.osx": "/bin/zsh",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.scrollback": 10000,
  "terminal.integrated.persistentSessionReviveProcess": "never",

  // ── Telemetry ─────────────────────────────────────────────────────────────
  "telemetry.telemetryLevel": "off",
  "redhat.telemetry.enabled": false,

  // ── Misc ──────────────────────────────────────────────────────────────────
  "extensions.autoUpdate": false,
  "update.mode": "manual",
  "breadcrumbs.enabled": true,
  "search.exclude": {
    "**/node_modules": true,
    "**/.git": true,
    "**/dist": true,
    "**/build": true,
    "**/__pycache__": true,
    "**/.venv": true
  },
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true,
    "**/.venv/**": true
  }
}
EOF

# ── Write VS Code settings ────────────────────────────────────────────────────
VSCODE_DIR="${HOME}/Library/Application Support/Code/User"
if [ -d "${HOME}/Library/Application Support/Code" ]; then
  mkdir -p "${VSCODE_DIR}"
  echo "${SETTINGS_JSON}" > "${VSCODE_DIR}/settings.json"
  echo "  ✓ VS Code settings.json"
else
  echo "  ⚠ VS Code not installed — skipping"
fi

# ── Write Cursor settings ─────────────────────────────────────────────────────
CURSOR_DIR="${HOME}/Library/Application Support/Cursor/User"
if [ -d "${HOME}/Library/Application Support/Cursor" ]; then
  mkdir -p "${CURSOR_DIR}"
  echo "${SETTINGS_JSON}" > "${CURSOR_DIR}/settings.json"
  echo "  ✓ Cursor settings.json"
else
  echo "  ⚠ Cursor not installed — skipping"
fi

# ── Sublime Text preferences ──────────────────────────────────────────────────
# Mirrors .editorconfig values for the settings Sublime reads natively.
# Note: EditorConfig plugin (https://packagecontrol.io/packages/EditorConfig)
# should also be installed via Package Control for per-file overrides.

SUBLIME_DIR="${HOME}/Library/Application Support/Sublime Text/Packages/User"
if [ -d "${HOME}/Library/Application Support/Sublime Text" ]; then
  mkdir -p "${SUBLIME_DIR}"
  cat > "${SUBLIME_DIR}/Preferences.sublime-settings" << 'SUBLIME_EOF'
{
  // EditorConfig alignment
  "translate_tabs_to_spaces": true,
  "tab_size": 2,
  "detect_indentation": false,
  "default_encoding": "UTF-8",
  "default_line_ending": "unix",
  "ensure_newline_at_eof_on_save": true,
  "trim_trailing_white_space_on_save": true,

  // Font
  "font_face": "SF Mono",
  "font_size": 13,

  // UI
  "rulers": [88, 120],
  "line_numbers": true,
  "highlight_line": true,
  "scroll_past_end": false,

  // Behavior
  "save_on_focus_lost": false,
  "hot_exit": true,
  "remember_open_files": true,
  "show_definitions": false,
  "auto_complete_delay": 200,
  "update_check": false
}
SUBLIME_EOF
  echo "  ✓ Sublime Text Preferences.sublime-settings"
else
  echo "  ⚠ Sublime Text not installed — skipping"
fi

echo "  ✓ Editor settings complete"
echo ""
