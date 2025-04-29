#!/bin/bash
set -e

echo "🔤 Installing MesloLGS NF fonts..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fsSLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
curl -fsSLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
curl -fsSLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
curl -fsSLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
fc-cache -fv
cd ~

echo "🖥 Detecting terminal..."
term_program=${TERM_PROGRAM:-}
terminal_profile=${WT_SESSION:-}

if [[ "$term_program" == "iTerm.app" ]]; then
  echo "✅ Detected iTerm2. Please manually set MesloLGS NF via Preferences → Profiles → Text → Font."
elif grep -q 'wsl' /proc/version 2>/dev/null; then
  echo "✅ Detected WSL. Configuring Windows Terminal profile..."
  powershell.exe -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"
  WIN_TERM_JSON=$(wslpath "$(cmd.exe /c echo %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" | tr -d '\r')")
  if [ -f "$WIN_TERM_JSON" ]; then
    sed -i 's/"fontFace": ".*"/"fontFace": "MesloLGS NF"/g' "$WIN_TERM_JSON"
    echo "✔ Updated Windows Terminal font to MesloLGS NF."
  else
    echo "⚠ Could not find settings.json for Windows Terminal. Please update it manually."
  fi
elif [[ "$term_program" == "vscode" ]]; then
  echo "✅ Detected VS Code. Updating settings.json..."
  SETTINGS_PATH="$HOME/.config/Code/User/settings.json"
  mkdir -p $(dirname "$SETTINGS_PATH")
  if [ ! -f "$SETTINGS_PATH" ]; then echo '{}' > "$SETTINGS_PATH"; fi
  jq '. + {"terminal.integrated.fontFamily": "MesloLGS NF"}' "$SETTINGS_PATH" > "$SETTINGS_PATH.tmp" && mv "$SETTINGS_PATH.tmp" "$SETTINGS_PATH"
  echo "✔ Updated VS Code terminal font to MesloLGS NF."
else
  echo "🛠 Unknown terminal. Please set MesloLGS NF manually in your terminal preferences."
fi