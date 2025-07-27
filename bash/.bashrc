# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

if [[ -r "$HOME/.config/osh.env" ]]; then
  . "$HOME/.config/osh.env"
fi
if [[ -r "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi
if [[ -r "$HOME/.bashrc.env" ]]; then
  . "$HOME/.bashrc.env"
fi

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpg-connect-agent updatestartuptty /bye > /dev/null
