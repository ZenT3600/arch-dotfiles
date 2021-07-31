#!/usr/bin/bash

ls -a dotfiles | xargs -I {} sh -c "ln -f -s $PWD/dotfiles/{} ~/{} &> /dev/null && echo \"Linked {}\" || echo \"Skipping {}\""
