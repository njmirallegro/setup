#!/bin/bash

set -e  # Exit immediately if a command fails

echo "Updating package list..."
sudo apt update

echo "Installing required packages: zsh, git, curl, fzf..."
sudo apt install -y zsh git curl fzf

echo "Installing Oh My Zsh..."
# Install Oh My Zsh without prompting
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

echo "Installing Zsh plugins..."

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# Install zsh-vi-mode
git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-mode

echo "Configuring .zshrc..."

# Set Powerlevel10k as the theme
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Replace plugins line
sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search vi-mode docker extract fzf)' ~/.zshrc

# Source plugin setup for history-substring-search and syntax-highlighting (they require manual sourcing order sometimes)
echo "
# Required for history substring search to work correctly
source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
" >> ~/.zshrc

echo "Setting Zsh as the default shell for the current user..."
chsh -s $(which zsh)

echo "Done! Please restart your terminal session or run 'exec zsh' to start using Zsh."
