#!/bin/zsh

# This file ensures proper initialization of zsh settings
# Put this in ~/.zprofile to run before zshrc when login shells start

# Force a reload of the FZF environment
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Other login-specific configuration can go here
