#!/bin/bash

DOTFILES="$HOME/dotfiles"

# Array of dotfiles to symlink
files=(".vimrc" ".bashrc" ".gitconfig" ".tmux.conf" ".zshrc")
config_dirs=(".config")

# Create symlinks for individual files
for file in "${files[@]}"; do
    if [ -f "$HOME/$file" ]; then
        echo "Backing up existing $file"
        mv "$HOME/$file" "$HOME/$file.backup"
    fi
    echo "Creating symlink for $file"
    ln -s "$DOTFILES/$file" "$HOME/$file"
done

# Handle .config directory
for dir in "${config_dirs[@]}"; do
    if [ -d "$HOME/$dir" ]; then
        echo "Backing up existing $dir"
        mv "$HOME/$dir" "$HOME/$dir.backup"
    fi
    echo "Creating symlink for $dir"
    ln -s "$DOTFILES/$dir" "$HOME/$dir"
done

# Source the bash configuration
source "$HOME/.bashrc"

echo "Dotfiles setup complete!"
