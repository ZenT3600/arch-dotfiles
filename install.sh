#!/usr/bin/bash

ls -a dotfiles | xargs -I {} sh -c "ln -f -s $PWD/dotfiles/{} ~/{} &> /dev/null && echo \"Linked {}\" || echo \"Skipping {}\""
find dotfiles -maxdepth 1 -mindepth 1 -type d | xargs -I {} basename {} | xargs -I {} sh -c "mv -f ~/{} ~/.config/ &> /dev/null && echo \"Moved config folder {} to correct location\" || echo \"Failed moving {}\""
ln -f -s $PWD/scripts/ -T $HOME/.scripts &> /dev/null && echo "Linked Scripts Folder" || echo "Skipping Scripts Folder"
