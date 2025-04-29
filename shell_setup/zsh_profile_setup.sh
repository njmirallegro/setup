#!/bin/bash

set -e  # Exit immediately if a command fails

# Detect platform
platform=""
if grep -qi microsoft /proc/version 2>/dev/null; then
  platform="wsl"
elif [[ "$(uname)" == "Darwin" ]]; then
  platform="mac"
else
  echo "Unsupported platform. Only WSL and macOS are supported."
  exit 1
fi

# Update and install basics
if [[ "$platform" == "wsl" ]]; then
  echo "Detected WSL. Installing packages with apt..."
  sudo apt update
  sudo apt install -y zsh git curl fzf bat exa ripgrep fd-find lsd docker.io
elif [[ "$platform" == "mac" ]]; then
  echo "Detected Mac. Installing packages with brew..."
  brew update
  brew install zsh git curl fzf bat exa ripgrep fd lsd docker
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Powerlevel10k
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
fi

# Install Zsh Plugins
echo "Installing Zsh plugins..."
PLUGINS_DIR=$HOME/.oh-my-zsh/custom/plugins
mkdir -p "$PLUGINS_DIR"
[ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
[ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"
[ ! -d "$PLUGINS_DIR/zsh-history-substring-search" ] && git clone https://github.com/zsh-users/zsh-history-substring-search "$PLUGINS_DIR/zsh-history-substring-search"
[ ! -d "$PLUGINS_DIR/zsh-vi-mode" ] && git clone https://github.com/jeffreytse/zsh-vi-mode "$PLUGINS_DIR/zsh-vi-mode"

# Configure .zshrc
echo "Configuring .zshrc..."
sed -i.bak '/^ZSH_THEME=/c\
ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc || true
sed -i.bak '/^plugins=/c\
plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search vi-mode docker extract fzf)' ~/.zshrc || true

# Ensure .zshrc sources .p10k.zsh
if ! grep -q ".p10k.zsh" ~/.zshrc; then
  echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
fi

# Download custom .p10k.zsh from GitHub
curl -fsSL https://raw.githubusercontent.com/njmirallegro/setup/main/.p10k.zsh -o ~/.p10k.zsh

# Set default shell to Zsh
ZSH_PATH=""
if [[ "$platform" == "mac" ]]; then
  ZSH_PATH="$(brew --prefix)/bin/zsh"
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
else
  ZSH_PATH="$(which zsh)"
fi

chsh -s "$ZSH_PATH"

# Add Modern Tool Aliases
cat << 'EOF' >> ~/.zshrc

# --- Modern CLI Tool Aliases ---
alias ls='exa --icons --group-directories-first'
# alias ls='lsd'  # alternatively
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
EOF

# Done
echo "\n✅ Setup complete! Restart your terminal or run 'exec zsh' to start using your new setup."

# Additional Instructions:
echo "\n📦 Docker has been installed. You may need to start the Docker service manually on Linux."
