#!/usr/bin/bash

ls -a dotfiles | xargs -I {} sh -c "ln -f -s $PWD/dotfiles/{} ~/{} &> /dev/null && echo \"Linked {}\" || echo \"Skipping {}\""
ln -f -s $PWD/scripts/ -T $HOME/.scripts &> /dev/null && echo "Linked Scripts Folder" || echo "Skipping Scripts Folder"
