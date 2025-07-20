#
#    ______          __     ____                 __  ______ 
#   / ____/___  ____/ /__  / __ \____  _____    / / / / __ \
#  / /   / __ \/ __  / _ \/ / / / __ \/ ___/   / /_/ / / / /
# / /___/ /_/ / /_/ /  __/ /_/ / /_/ (__  )   / __  / /_/ / 
# \____/\____/\__,_/\___/\____/ .___/____/   /_/ /_/\___\_\ 
#                            /_/
#

#######################################################
# SECTION 1: PROMPT AND SHELL INITIALIZATION
#######################################################

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Fix for xterm-kitty TERM on remote hosts
if [[ "$TERM" == "xterm-kitty" ]]; then
  export TERM=xterm-256color
fi

#######################################################
# SECTION 2: ENVIRONMENT VARIABLES
#######################################################

# Editor configuration
export EDITOR='nvim' 
export VISUAL='nvim' 
export SUDO_EDITOR=nvim
export FCEDIT=nvim
export TERMINAL=alacritty
export BROWSER=com.brave.Browser

# Vi mode settings
export KEYTIMEOUT=1  # Make vim mode transitions faster (in hundredths of a second)

# Bat configuration (if available)
if [[ -x "$(command -v bat)" ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export MANROFFOPT="-c"
fi

#######################################################
# SECTION 3: ZINIT PLUGIN MANAGER
#######################################################

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# zsh-vi-mode needs special handling because it overrides keybindings
zinit light jeffreytse/zsh-vi-mode

# Snippets from Oh-My-Zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
# zinit snippet OMZP::tmuxinator
zinit snippet OMZP::docker
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#######################################################
# SECTION 4: ZSH BASIC OPTIONS
#######################################################

setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form 'anything=expression'
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

#######################################################
# SECTION 5: HISTORY CONFIGURATION
#######################################################

# Where and how much history is stored
HISTSIZE=10000                    # In-memory history size
SAVEHIST=$HISTSIZE                # Number of lines saved to file
HISTFILE=~/.zsh_history           # History file path

# History behavior options
setopt APPEND_HISTORY             # Append history instead of overwriting
setopt INC_APPEND_HISTORY         # Add commands to history immediately
setopt SHARE_HISTORY              # Share history across terminals

# Duplicates and whitespace cleanup
setopt HIST_IGNORE_SPACE          # Ignore commands starting with space
setopt HIST_IGNORE_ALL_DUPS       # Remove all old duplicates of a command
setopt HIST_SAVE_NO_DUPS          # Don't save duplicate lines
setopt HIST_IGNORE_DUPS           # Don't store duplicates from same session
setopt HIST_FIND_NO_DUPS          # Don't show duplicates when searching
setopt HIST_REDUCE_BLANKS         # Trim excess whitespace in commands

#######################################################
# SECTION 6: FZF CONFIGURATION
#######################################################

if [[ -x "$(command -v fzf)" ]]; then
	# FZF Commands configuration
	export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

	# FZF appearance and behavior
	export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	  --height 40% \
	  --layout=default \
	  --border \
	  --color=hl:#2dd4bf \
	  --info=inline-right \
	  --ansi \
	  --border=rounded \
	  --color=border:#27a1b9 \
	  --color=fg:#c0caf5 \
	  --color=gutter:#16161e \
	  --color=header:#ff9e64 \
	  --color=hl+:#2ac3de \
	  --color=info:#545c7e \
	  --color=marker:#ff007c \
	  --color=pointer:#ff007c \
	  --color=prompt:#2ac3de \
	  --color=query:#c0caf5:regular \
	  --color=scrollbar:#27a1b9 \
	  --color=separator:#ff9e64 \
	  --color=spinner:#ff007c \
	"

	# FZF preview settings
	export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
	export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"
fi

#######################################################
# SECTION 7: ZSH FUNCTIONS
#######################################################

# Custom function for Yazi file manager with directory tracking
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ZLE function to launch Yazi
_launch_yazi() {
  BUFFER="y"
  zle accept-line
}
zle -N _launch_yazi

# ZLE function to show shortcuts
_show_shortcuts() {
  if [[ -x "$(command -v bat)" ]]; then
    bat --style=full --language=markdown --color=always ~/dotfiles/zsh_shortcuts.txt
  else
    cat ~/dotfiles/zsh_shortcuts.txt
  fi
  zle reset-prompt
}
zle -N _show_shortcuts

# Cursor shape function for vi mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q' # Block cursor for normal mode
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q' # Beam cursor for insert mode
  fi
}
zle -N zle-keymap-select

# Start a program but immediately disown it and detach it from the terminal
function runfree() {
	"$@" > /dev/null 2>&1 & disown
}

# Copy file with a progress bar
function cpp() {
	if [[ -x "$(command -v rsync)" ]]; then
		rsync -ah --info=progress2 "${1}" "${2}"
	else
		set -e
		strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
		| awk '{
		count += $NF
		if (count % 10 == 0) {
			percent = count / total_size * 100
			printf "%3d%% [", percent
			for (i=0;i<=percent;i++)
				printf "="
				printf ">"
				for (i=percent;i<100;i++)
					printf " "
					printf "]\r"
				}
			}
		END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
	fi
}

# Copy and go to the directory
function cpg() {
	if [[ -d "$2" ]];then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
function mvg() {
	if [[ -d "$2" ]];then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
function mkdirg() {
	mkdir -p "$@" && cd "$@"
}

# Prints random height bars across the width of the screen
function random_bars() {
	columns=$(tput cols)
	chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
	for ((i = 1; i <= $columns; i++))
	do
		echo -n "${chars[RANDOM%${#chars} + 1]}"
	done
	echo
}

# PATH management functions
function pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

function pathprepend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

#######################################################
# SECTION 8: ZSH KEYBINDINGS
#######################################################

# Enable vi mode
bindkey -v

# Fix for the slow escape in vim mode
bindkey -M viins 'jk' vi-cmd-mode  # Press 'jk' to exit insert mode quickly

# Bind keys for both vi insert and command modes
bindkey -M viins '^p' history-search-backward
bindkey -M vicmd '^p' history-search-backward
bindkey -M viins '^n' history-search-forward
bindkey -M vicmd '^n' history-search-forward
bindkey -M viins ' ' magic-space                           # do history expansion on space
bindkey -M viins "^[[A" history-beginning-search-backward  # search history with up key
bindkey -M viins "^[[B" history-beginning-search-forward   # search history with down key

# Custom FZF and Yazi shortcuts - bind to both insert and normal modes
bindkey -M viins '^f' fzf-file-widget                      # Ctrl+F to open FZF file finder
bindkey -M vicmd '^f' fzf-file-widget
bindkey -M viins '^t' fzf-file-widget                      # Ctrl+T to open FZF file finder (standard)
bindkey -M vicmd '^t' fzf-file-widget
bindkey -M viins '^g' fzf-cd-widget                        # Ctrl+G to open FZF directory finder
bindkey -M vicmd '^g' fzf-cd-widget
bindkey -M viins '\ec' fzf-cd-widget                       # Alt+C to open FZF directory finder (standard)
bindkey -M vicmd '\ec' fzf-cd-widget
bindkey -M viins '^r' fzf-history-widget                   # Ctrl+R to search command history with FZF
bindkey -M vicmd '^r' fzf-history-widget
bindkey -M viins '^e' _launch_yazi                         # Ctrl+E to launch Yazi file manager
bindkey -M vicmd '^e' _launch_yazi
bindkey -M viins '^_' _show_shortcuts                      # Ctrl+? to show ZSH shortcuts
bindkey -M vicmd '^_' _show_shortcuts

# Ensure cursor shape is properly initialized
# echo -ne '\e[5 q'  # Initialize cursor to beam shape on startup

#######################################################
# SECTION 9: ZSH VI MODE PLUGIN CONFIGURATION
#######################################################

# Cursor style settings for zsh-vi-mode plugin
# ZVM_CURSOR_STYLE_ENABLED=false  # Uncomment to disable cursor style changes
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE

# Function to run after zsh-vi-mode has initialized
function zvm_after_init() {
  # Ensure FZF widgets are properly bound
  autoload -U is-at-least
  if is-at-least 5.2; then
    # Use the new style for 5.2 and above
    autoload -Uz add-zle-hook-widget
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
  fi

  # Rebind our custom keys for both modes
  bindkey -M viins '^p' history-search-backward
  bindkey -M vicmd '^p' history-search-backward
  bindkey -M viins '^n' history-search-forward
  bindkey -M vicmd '^n' history-search-forward
  bindkey -M viins ' ' magic-space                           # do history expansion on space
  bindkey -M viins "^[[A" history-beginning-search-backward  # search history with up key
  bindkey -M viins "^[[B" history-beginning-search-forward   # search history with down key
  
  # Custom FZF and Yazi shortcuts - bind to both insert and normal modes
  bindkey -M viins '^f' fzf-file-widget                      # Ctrl+F to open FZF file finder
  bindkey -M vicmd '^f' fzf-file-widget
  bindkey -M viins '^t' fzf-file-widget                      # Ctrl+T to open FZF file finder (standard)
  bindkey -M vicmd '^t' fzf-file-widget
  bindkey -M viins '^g' fzf-cd-widget                        # Ctrl+G to open FZF directory finder
  bindkey -M vicmd '^g' fzf-cd-widget
  bindkey -M viins '\ec' fzf-cd-widget                       # Alt+C to open FZF directory finder (standard)
  bindkey -M vicmd '\ec' fzf-cd-widget
  bindkey -M viins '^r' fzf-history-widget                   # Ctrl+R to search command history with FZF
  bindkey -M vicmd '^r' fzf-history-widget
  bindkey -M viins '^e' _launch_yazi                         # Ctrl+E to launch Yazi file manager
  bindkey -M vicmd '^e' _launch_yazi
  bindkey -M viins '^_' _show_shortcuts                      # Ctrl+? to show ZSH shortcuts
  bindkey -M vicmd '^_' _show_shortcuts
}

#######################################################
# SECTION 10: COMPLETION STYLING
#######################################################

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

#######################################################
# SECTION 11: ALIASES
#######################################################

# History and navigation
alias h='fc -l 1 | nvim -R +$ -'     # View clean shell history in Neovim (read-only)
alias c='clear'
alias q='exit'
alias ..='cd ..'

# File operations with safety
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'

# Listing files with eza
alias ls='eza --all --header --long -h --icons --group-directories-first $eza_params'
alias lsm='eza --all --header --long -h --icons --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'

# Neovim aliases
if [[ -x "$(command -v nvim)" ]]; then
	alias vi='nvim'
	alias vim='nvim'
	alias svi='sudo nvim'
	alias vis='nvim "+set si"'
elif [[ -x "$(command -v vim)" ]]; then
	alias vi='vim'
	alias svi='sudo vim'
	alias vis='vim "+set si"'
fi

# Bat as cat replacement
if [[ -x "$(command -v bat)" ]]; then
    alias cat='bat'
fi

# FZF aliases
if [[ -x "$(command -v fzf)" ]]; then
    # Interactive FZF with preview
    alias fzfi='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
    # File preview and open
	if [[ -x "$(command -v xdg-open)" ]]; then
		alias preview='open $(fzf --info=inline --query="${@}")'
	else
		alias preview='edit $(fzf --info=inline --query="${@}")'
	fi
fi

#######################################################
# SECTION 12: PATH CONFIGURATION
#######################################################

# Add personal binary paths
pathprepend "$HOME/bin" "$HOME/sbin" "$HOME/.local/bin" "$HOME/local/bin" "$HOME/.bin"

# Add Rust cargo binaries
pathappend "$HOME/.cargo/bin"

# Add Tmuxifier to path
pathappend "$HOME/.config/tmux/plugins/tmuxifier/bin"

# Console Ninja
PATH=~/.console-ninja/.bin:$PATH

#######################################################
# SECTION 13: EXTERNAL SOURCES AND INTEGRATIONS
#######################################################

# ZSH Syntax highlighting
source ~/.config/zsh/zsh-syntax-highlightin-tokyonight.zsh

# Set up fzf key bindings and fuzzy completion
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif command -v fzf &>/dev/null; then
  # Try the new --zsh flag first, fall back to older methods
  if fzf --zsh &>/dev/null; then
    source <(fzf --zsh)
  else
    # Fallback for older FZF versions
    if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
      source /usr/share/fzf/key-bindings.zsh
    fi
    if [[ -f /usr/share/fzf/completion.zsh ]]; then
      source /usr/share/fzf/completion.zsh
    fi
  fi
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Zoxide config (commented out)
# eval "$(zoxide init --cmd cd zsh)"

# Tmuxifier config (commented out)
# eval "$(tmuxifier init -)"

# Initialize cursor to beam shape on startup (moved to end to avoid P10k instant prompt issues)
echo -ne '\e[5 q'
