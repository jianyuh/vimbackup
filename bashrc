# ~/.bashrc

## My customizations 

## Colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

## Devserver connect helpers
#
# Attach to (or create) a tmux session on a devserver.
#
# Two problems with the old `mosh -6 HOST -- tmux a` form:
#   1. `tmux a` fails outright when no session exists yet.
#   2. A tmux package upgrade (3.5a -> 3.7b) deletes the binary out from
#      under a long-lived tmux server. The new on-disk client cannot attach
#      to the still-running old server and reports the misleading
#      "open terminal failed: not a terminal".
#
# Recover the old binary on an affected host with:
#   P=<pid of "tmux: server">   # from: ps -u $USER -o pid,comm,args | grep tmux
#   mkdir -p ~/bin && cp /proc/$P/exe ~/bin/tmux-old && chmod +x ~/bin/tmux-old
#
# These helpers prefer ~/bin/tmux-old, but only when it can actually reach a
# server holding the session -- so they keep working on healthy hosts, and
# after the old server is finally retired.
#
# Usage: devmosh HOST [SESSION]   (SESSION defaults to "main")

# Remote script, run as: sh -lc "$_DEV_TMUX_SCRIPT" <name> [SESSION]
#   $1 = session name; empty means "most recently used", i.e. old `tmux a`.
# Passing the session as a positional arg (rather than interpolating it)
# keeps this a plain single-quoted string with no escaping.
#
# Picks the tmux binary that can actually reach the running server, and
# self-heals: if a package upgrade deleted the binary out from under a
# long-lived server, recover it from /proc and use that.
_DEV_TMUX_SCRIPT='
  T=$HOME/bin/tmux-old
  works() { [ -x "$1" ] && "$1" list-sessions >/dev/null 2>&1; }

  if ! works "$T"; then
    for p in $(ps -u "$(id -un)" -o pid=,comm= | awk "/tmux: server/ {print \$1}"); do
      case $(readlink /proc/$p/exe 2>/dev/null) in
        *"(deleted)")
          mkdir -p "$HOME/bin" && cp /proc/$p/exe "$T" && chmod +x "$T"
          echo "devmosh: recovered $("$T" -V) to $T" >&2
          break ;;
      esac
    done
    works "$T" || T=tmux
  fi

  if [ -n "$1" ]; then
    exec "$T" new-session -A -s "$1"
  elif "$T" list-sessions >/dev/null 2>&1; then
    exec "$T" attach -d
  else
    exec "$T" new-session -s main
  fi
'

devmosh() { mosh -6 "$1" -- sh -lc "$_DEV_TMUX_SCRIPT" devmosh "$2"; }
devssh()  { ssh  -t "$1" -- sh -lc "$_DEV_TMUX_SCRIPT" devssh  "$2"; }

# Example host alias:
#   alias dev='devmosh <your-devserver-hostname>'

export HGEDITOR=vim
export EDITOR=vim

## Git command line display
function git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
  echo "("${ref#refs/heads/}") ";
}

function git_since_last_commit {
  now=`date +%s`;
  last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;
  seconds_since_last_commit=$((now-last_commit));
  minutes_since_last_commit=$((seconds_since_last_commit/60));
  hours_since_last_commit=$((minutes_since_last_commit/60));
  minutes_since_last_commit=$((minutes_since_last_commit%60));
  echo "${hours_since_last_commit}h${minutes_since_last_commit}m ";
}

#PS1="[\[\033[1;32m\]\u@\h: \W\[\033[0m\]] \[\033[0m\]\[\033[1;36m\]\$(git_branch)\[\033[0;33m\]\$(git_since_last_commit)\[\033[0m\]$ "
PS1="[\[\033[1;32m\]\u@\H: \w\[\033[0m\]] \[\033[0m\]\[\033[1;36m\]\$(git_branch)\[\033[0;33m\]\$(git_since_last_commit)\[\033[0m\]$ "


## Common alias

alias gitk='gitk --all &'
alias ml='module list'
alias ma='module avail'
alias rm='rm -i'
alias ..='cd ..'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias du='du -kh'
#alias ls='ls -h --color'
alias h='history'
alias j='jobs -l'

