#!/bin/bash

# Check if Ruby is installed
if ! command -v ruby &> /dev/null
then
    echo "Ruby is required but not installed, continue to install Ruby"
    sudo apt-get update
    sudo apt-get install -y ruby-full
    echo "Ruby installation complete."
fi

# This makes it possible to run nial-code by writing "nial filename.nial"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if ! grep -q "alias nial='ruby $SCRIPT_DIR/source/nial.rb'" ~/.bashrc; then
    echo "alias nial='ruby $SCRIPT_DIR/source/nial.rb'" >> ~/.bashrc
    echo "Nial was installed successfully"
else
    echo "Nial is already installed"
fi

# This adds nial-mode to emacs
if [ ! -d ~/.emacs.d/nial-mode ]; then
    mkdir -p ~/.emacs.d/nial-mode
    cp tools/nial-mode.el ~/.emacs.d/nial-mode/nial-mode.el
    echo "(load \"~/.emacs.d/nial-mode/nial-mode.el\")" >> ~/.emacs
    echo "(add-to-list 'auto-mode-alist '(\"\\\\.nial\\\\'\" . nial-mode))" >> ~/.emacs
    echo "Nial-mode for Emacs was installed successfully"
else
    echo "Nial-mode for Emacs already installed"
fi

echo "Creating documentation..."
rdoc source -d
echo "Documentation was created succesfully!"

echo "Installation complete!"

source ~/.bashrc
