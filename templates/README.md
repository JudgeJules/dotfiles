# Project Templates

Starter files for new projects. Copy the relevant flavor into your project root.

## Usage

```bash
# Python project
cp ~/.local/share/chezmoi/templates/python/Justfile ./Justfile
cp ~/.local/share/chezmoi/templates/python/.envrc ./.envrc
direnv allow

# Node project
cp ~/.local/share/chezmoi/templates/node/Justfile ./Justfile
cp ~/.local/share/chezmoi/templates/node/.envrc ./.envrc
direnv allow
```

## What's included

| File | Purpose |
|------|---------|
| `Justfile` | Task runner — `just install`, `just dev`, `just test`, `just fmt`, `just clean` |
| `.envrc` | direnv config — activates venv/Node version, loads `.env`, sets PYTHONPATH |

## After copying

- **Python**: run `just install` to create the venv, then edit `dev:` recipe to point at your entrypoint
- **Node**: add a `.nvmrc` with your Node version (e.g. `lts/iron`), then run `just install`
- Both: add `.env` to your `.gitignore`
