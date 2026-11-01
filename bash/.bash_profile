# .bash_profile -*- mode: sh -*-

# Load interactive settings
if [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
