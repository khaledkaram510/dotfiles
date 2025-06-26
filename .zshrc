#
#    ______          __     ____                 __  ______ 
#   / ____/___  ____/ /__  / __ \____  _____    / / / / __ \
#  / /   / __ \/ __  / _ \/ / / / __ \/ ___/   / /_/ / / / /
# / /___/ /_/ / /_/ /  __/ /_/ / /_/ (__  )   / __  / /_/ / 
# \____/\____/\__,_/\___/\____/ .___/____/   /_/ /_/\___\_\ 
#                            /_/
#
#
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
zinit light jeffreytse/zsh-vi-mode

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
# zinit snippet OMZP::tmuxinator
zinit snippet OMZP::docker
zinit snippet OMZP::command-not-found

# Disable the cursor style feature
# ZVM_CURSOR_STYLE_ENABLED=false
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#######################################################
# ZSH Basic Options
#######################################################

setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

#######################################################
# Environment Variables
#######################################################
# export EDITOR=nvim
# export VISUAL=nvim
export EDITOR=nvim visudo
export VISUAL=nvim visudo
export SUDO_EDITOR=nvim
export FCEDIT=nvim
export TERMINAL=alacritty
export BROWSER=com.brave.Browser

if [[ -x "$(command -v bat)" ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export MANROFFOPT="-c"
fi

if [[ -x "$(command -v fzf)" ]]; then
	export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	  --info=inline-right \
	  --ansi \
	  --layout=reverse \
	  --border=rounded \
	  --color=border:#27a1b9 \
	  --color=fg:#c0caf5 \
	  --color=gutter:#16161e \
	  --color=header:#ff9e64 \
	  --color=hl+:#2ac3de \
	  --color=hl:#2ac3de \
	  --color=info:#545c7e \
	  --color=marker:#ff007c \
	  --color=pointer:#ff007c \
	  --color=prompt:#2ac3de \
	  --color=query:#c0caf5:regular \
	  --color=scrollbar:#27a1b9 \
	  --color=separator:#ff9e64 \
	  --color=spinner:#ff007c \
	"
fi

#######################################################
# ZSH Keybindings
#######################################################

bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# bindkey '^[w' kill-region
bindkey ' ' magic-space                           # do history expansion on space
bindkey "^[[A" history-beginning-search-backward  # search history with up key
bindkey "^[[B" history-beginning-search-forward   # search history with down key

#######################################################
# History Configuration (Improved)
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
# Completion styling
#######################################################

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

#######################################################
# Add Common Binary Directories to Path
#######################################################

# Add directories to the end of the path if they exist and are not already in the path
# Link: https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
function pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

# Add directories to the beginning of the path if they exist and are not already in the path
function pathprepend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

# y shell wrapper that provides the ability to change the current working directory when exiting Yazi.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Add the most common personal binary paths located inside the home folder
# (these directories are only added if they exist)
pathprepend "$HOME/bin" "$HOME/sbin" "$HOME/.local/bin" "$HOME/local/bin" "$HOME/.bin"

# Check for the Rust package manager binary install location
# Link: https://doc.rust-lang.org/cargo/index.html
pathappend "$HOME/.cargo/bin"

# Add Tmuxifier to path
pathappend "$HOME/.config/tmux/plugins/tmuxifier/bin"

#######################################################
# Aliases
#######################################################

# alias h='fc -l 1 | less'           # Make 'history' open in less (readable/scrollable)
alias h='fc -l 1 | nvim -R +$ -'     # View clean shell history in Neovim (read-only)
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'
# alias ls='ls --color=auto -F --group-directories-first -lah'
# alias ls='eza $eza_params'
# alias l='eza --git-ignore $eza_params'
alias ls='eza --all --header --long $eza_params'
alias lsm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'
# alias grep='grep --color=auto'
# alias fgrep='fgrep --color=auto'
# alias egrep='egrep --color=auto'

# Alias for neovim
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

# # Alias for lsd
# if [[ -x "$(command -v lsd)" ]]; then
# 	alias ls='lsd -F --group-dirs first'
# 	alias ll='lsd --all --header --long --group-dirs first'
# 	alias tree='lsd --tree'
# fi

# # Alias to launch a document, file, or URL in it's default X application
# if [[ -x "$(command -v xdg-open)" ]]; then
# 	alias open='runfree xdg-open'
# fi

# # Alias to launch a document, file, or URL in it's default PDF reader
# if [[ -x "$(command -v evince)" ]]; then
#     alias pdf='runfree evince'
# fi

# # Alias For bat
# # Link: https://github.com/sharkdp/bat
if [[ -x "$(command -v bat)" ]]; then
    alias cat='bat'
fi

# # Alias for lazygit
# # Link: https://github.com/jesseduffield/lazygit
# if [[ -x "$(command -v lazygit)" ]]; then
#     alias lg='lazygit'
# fi

# Alias for FZF
# Link: https://github.com/junegunn/fzf
if [[ -x "$(command -v fzf)" ]]; then
    alias fzf='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
    # Alias to fuzzy find files in the current folder(s), preview them, and launch in an editor
	if [[ -x "$(command -v xdg-open)" ]]; then
		alias preview='open $(fzf --info=inline --query="${@}")'
	else
		alias preview='edit $(fzf --info=inline --query="${@}")'
	fi
fi

# # Get local IP addresses
# if [[ -x "$(command -v ip)" ]]; then
#     alias iplocal="ip -br -c a"
# else
#     alias iplocal="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
# fi

# # Get public IP addresses
# if [[ -x "$(command -v curl)" ]]; then
#     alias ipexternal="curl -s ifconfig.me && echo"
# elif [[ -x "$(command -v wget)" ]]; then
#     alias ipexternal="wget -qO- ifconfig.me && echo"
# fi


#######################################################
# Functions
#######################################################

# Start a program but immediately disown it and detach it from the terminal
function runfree() {
	"$@" > /dev/null 2>&1 & disown
}

# Copy file with a progress bar
function cpp() {
	if [[ -x "$(command -v rsync)" ]]; then
		# rsync -avh --progress "${1}" "${2}"
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
# (great with lolcat application on new terminal windows)
function random_bars() {
	columns=$(tput cols)
	chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
	for ((i = 1; i <= $columns; i++))
	do
		echo -n "${chars[RANDOM%${#chars} + 1]}"
	done
	echo
}

#######################################################
# ZSH Syntax highlighting
#######################################################
source ~/.config/zsh/zsh-syntax-highlightin-tokyonight.zsh

#######################################################
# Shell integrations
#######################################################

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Zoxide config for zsh plugins 
# eval "$(zoxide init --cmd cd zsh)"


# Tmuxifier config for zsh plugins  
# eval "$(tmuxifier init -)"




PATH=~/.console-ninja/.bin:$PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Fix for xterm-kitty TERM on remote hosts
if [[ "$TERM" == "xterm-kitty" ]]; then
  export TERM=xterm-256color
fi

