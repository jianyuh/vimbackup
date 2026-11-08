#!/bin/bash
# Set up vim, bash and git config on a new Mac (or Linux box) from this repo.
# Usage: git clone git@github.com:jianyuh/vimbackup.git ~/Work/Github/vimbackup
#        ~/Work/Github/vimbackup/install.sh
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

link() {  # link <repo-relative source> <target in $HOME>
  local src="$REPO${1:+/$1}" dst="$HOME/$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      ~/$2"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP"; mv "$dst" "$BACKUP/"
    echo "backup  ~/$2 -> $BACKUP/"
  fi
  ln -s "$src" "$dst"
  echo "link    ~/$2 -> $src"
}

link ""             .vim
link vimrc          .vimrc
link bashrc         .bashrc
link bash_profile   .bash_profile
link gitconfig      .gitconfig

# Vim plugins (Vundle itself is tracked in the repo)
vim +PluginInstall +qall </dev/null >/dev/null 2>&1 || echo "warn    :PluginInstall failed; run it inside vim"

if [[ "$OSTYPE" == darwin* ]]; then
  BREW=""
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && BREW="$b" && break; done
  if [ -z "$BREW" ]; then
    cat <<'MSG'

Homebrew is not installed. Install it, then re-run this script:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
MSG
    exit 0
  fi
  "$BREW" bundle --file="$REPO/Brewfile"

  BASH_BIN="$("$BREW" --prefix)/bin/bash"
  if ! grep -qx "$BASH_BIN" /etc/shells; then
    echo "Adding $BASH_BIN to /etc/shells (needs sudo)"
    echo "$BASH_BIN" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "$(dscl . -read "$HOME" UserShell | awk '{print $2}')" != "$BASH_BIN" ]; then
    echo "Switching login shell to $BASH_BIN"
    chsh -s "$BASH_BIN"
  fi
fi

echo
echo "Done. Quit and reopen your terminal, then check: echo \$SHELL \$BASH_VERSION"
