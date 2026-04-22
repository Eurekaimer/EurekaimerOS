# VS Code Migration Bundle (manual, no symlink)

This folder stores VS Code assets for migration across machines.

Included:
- `User/settings.json` (focused settings for LaTeX + PDF preview)
- `argv.json` (startup args, including GPU acceleration switch)
- `extensions/local.latex-pdf-bridge-0.0.2` (local bridge extension)

Manual sync (example):

```bash
mkdir -p ~/.config/Code/User ~/.vscode/extensions
cp /etc/nixos/modules/home/config/.vscode/User/settings.json ~/.config/Code/User/settings.json
cp /etc/nixos/modules/home/config/.vscode/argv.json ~/.vscode/argv.json
rm -rf ~/.vscode/extensions/local.latex-pdf-bridge-0.0.2
cp -r /etc/nixos/modules/home/config/.vscode/extensions/local.latex-pdf-bridge-0.0.2 ~/.vscode/extensions/
```

Then restart VS Code (or run `Developer: Reload Window`).
