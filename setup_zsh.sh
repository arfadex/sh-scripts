#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y zsh git curl

# Change the default shell to zsh
if ! grep -Fxq "$(which zsh)" /etc/shells; then
    echo "$(which zsh)" | sudo tee -a /etc/shells
fi
sudo chsh -s $(which zsh) "$USER"

# Install Oh My Zsh if it's not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Clone the syntax highlighting plugin if it doesn't exist
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Clone the autosuggestions plugin if it doesn't exist
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Add plugins to .zshrc if not already present
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
  sed -i "s/^plugins=(git)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc
fi

# Configure the prompt
if ! grep -q "autoload -U colors && colors" ~/.zshrc; then
  echo 'autoload -U colors && colors' >> ~/.zshrc
fi
if ! grep -q 'PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "' ~/.zshrc; then
  echo 'PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "' >> ~/.zshrc
fi

# Feedback to user
echo "Zsh has been set up with syntax highlighting, autocompletion, and a colored prompt."
echo "Please start a new Zsh session by typing 'zsh' or opening a new terminal to apply the changes."
