# .bash_profile -*- mode: sh -*-

# Load login settings and environment variables
if [[ -f ~/.profile ]]; then
  source ~/.profile
fi

# Load interactive settings
if [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi
. "$HOME/.cargo/env"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
