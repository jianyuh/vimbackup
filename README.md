# vimbackup

My vim, bash and git configuration. The repo itself is `~/.vim`.

## Quick start (human)

```bash
# macOS: install Homebrew first (https://brew.sh)
git clone git@github.com:jianyuh/vimbackup.git ~/Work/Github/vimbackup
~/Work/Github/vimbackup/install.sh
```

Then quit and reopen the terminal (iTerm2: `Cmd+Q`), and check `echo $SHELL $BASH_VERSION`.

**iTerm2 profile:** `Default_Black.json` is my iTerm2 profile (colors, font, login
shell). Import it and make it the default:

1. iTerm2 → Settings (`Cmd+,`) → **Profiles**.
2. Below the profile list, click **Other Actions…** → **Import JSON Profiles…**,
   and pick `~/Work/Github/vimbackup/Default_Black.json`.
3. Select the new **Default_Black** profile → **Other Actions…** → **Set as Default**.
4. Open a new window (`Cmd+N`).

To save changes back to the repo later: select the profile → **Other Actions…** →
**Save Profile as JSON…** and overwrite `Default_Black.json`.

`install.sh` is safe to re-run. It:

1. Symlinks `~/.vim`, `~/.vimrc`, `~/.bashrc`, `~/.bash_profile`, `~/.gitconfig`
   to this repo (anything already there is moved to `~/.dotfiles-backup-<timestamp>/`).
2. Runs `:PluginInstall` (Vundle) to fetch plugins into `bundle/`.
3. On macOS: `brew bundle` from `Brewfile`, adds Homebrew bash to `/etc/shells`
   and makes it the login shell (asks for the password).

---

## Setup instructions for Claude (or another coding agent)

Goal: on a fresh Mac, make vim + bash + git use this repo's config, with Homebrew
bash 5 as the login shell. Follow the steps in order. Steps marked **USER** need
the user's password or an interactive prompt — the agent cannot answer sudo/`chsh`
prompts, so hand the exact command to the user (in Claude Code: ask them to type
`! <command>`), then continue with the check.

### 0. Inspect first (do not overwrite blindly)

```bash
echo "$SHELL"; dscl . -read ~ UserShell
ls -la ~/.vim ~/.vimrc ~/.bashrc ~/.bash_profile ~/.gitconfig 2>&1
ls /opt/homebrew/bin/brew /usr/local/bin/brew 2>&1
```

If any of those dotfiles already exist and are not symlinks into this repo, tell
the user what is there before running the installer (it backs them up, but a real
`~/.vim` directory or an existing `~/.gitconfig` may hold things they want to merge).

### 1. Homebrew — **USER** (if `brew` is missing)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Check: `ls /opt/homebrew/bin/brew` (Apple Silicon) or `/usr/local/bin/brew` (Intel).

### 2. Clone (skip if already cloned)

```bash
git clone git@github.com:jianyuh/vimbackup.git ~/Work/Github/vimbackup
```

If SSH keys are not set up yet, use `https://github.com/jianyuh/vimbackup.git`.

### 3. Run the installer

```bash
~/Work/Github/vimbackup/install.sh
```

- Takes a few minutes (Homebrew installs). Run it in the background or with a long timeout.
- If the login shell is not yet Homebrew bash, the script runs `sudo tee -a /etc/shells`
  and `chsh`, which need a password. Run from an agent, this step fails with no terminal
  to ask for the password. In that case, have the **USER** run:
  ```bash
  echo /opt/homebrew/bin/bash | sudo tee -a /etc/shells
  chsh -s /opt/homebrew/bin/bash
  ```
  then re-run `install.sh` (it skips steps already done).

### 4. Verify

```bash
# symlinks point into the repo
for f in .vim .vimrc .bashrc .bash_profile .gitconfig; do printf '%-14s -> %s\n' "$f" "$(readlink ~/$f)"; done

# login shell
dscl . -read ~ UserShell                       # expect /opt/homebrew/bin/bash

# bash config loads in a login shell
bash -lic 'type devmosh >/dev/null && echo bashrc_ok'

# vim starts with no errors (needs a pty; empty output apart from the
# "Messages maintainer" line means no errors)
script -q /dev/null vim -c 'redir! > /tmp/vimmsg | silent messages | redir END | qa!' </dev/null >/dev/null 2>&1; cat /tmp/vimmsg

# plugins installed
ls ~/.vim/bundle                               # expect Vundle.vim, vim-fugitive

# git identity
git config --global user.email                 # expect hjyahead@gmail.com
```

### 5. iTerm2 profile — **USER** (if they use iTerm2)

The agent cannot click through iTerm2's settings. Give the user the steps from the
"iTerm2 profile" part of the quick start above: import `Default_Black.json`
(Settings → Profiles → Other Actions… → Import JSON Profiles…), then
**Set as Default**. That profile uses the login shell, so it picks up Homebrew bash.

Finally tell the user to quit and reopen their terminal (iTerm2 `Cmd+Q`), then
check `echo $SHELL $BASH_VERSION` → `/opt/homebrew/bin/bash 5.x`.

### Known pitfalls

- **Still zsh after reopening the terminal:** `chsh` was not run, or iTerm2 →
  Settings → Profiles → General → Command is a custom command instead of "Login Shell".
- **macOS Terminal/iTerm2 start login shells**, which read `~/.bash_profile`, not
  `~/.bashrc`. The repo's `bash_profile` loads `bashrc`; keep it linked.
- **`bashrc` returns early in non-interactive shells** (keeps scp/rsync quiet). Put
  anything non-interactive scripts need into `bash_profile` or `~/.bashrc.local`.
- **Machine-specific settings or secrets** go in `~/.bashrc.local` (not in git).
- **Do not link this repo's `.gitignore` as the global `~/.gitignore`** (which
  `gitconfig` names as `core.excludesfile`). It ignores `*.txt` and `*backup*`,
  which would hide those files in every repo.
- **Dim/dark text in iTerm2:** import `Default_Black.json` first. If text is still too
  dark, Settings → Profiles → Colors → raise "Minimum contrast", or lighten the ANSI
  "Bright Black" color, then re-export the profile over `Default_Black.json`.
- **Do not edit `install.sh` while it is running** (bash reads scripts as it runs them).
- **Python-based vim plugins:** macOS vim has no Python. ConqueTerm was moved to
  `disabled/`; use `:vertical terminal` instead.

---

## Layout

| Path | What |
| --- | --- |
| `install.sh` | Re-runnable setup script (symlinks, plugins, Homebrew, login shell) |
| `vimrc` | Vim config (Vundle plugins at the top) |
| `bashrc` | Bash config; macOS/Linux sections, `~/.bashrc.local` for machine-only settings |
| `bash_profile` | Loads `~/.bashrc` for login shells (macOS Terminal/iTerm2) |
| `gitconfig` | Git config |
| `Brewfile` | Homebrew packages |
| `Default_Black.json` | iTerm2 profile; import in Settings → Profiles → Other Actions… → Import JSON Profiles…, then Set as Default |
| `plugin/`, `autoload/`, `colors/`, ... | Bundled vim scripts |
| `disabled/` | Old plugins kept for reference, not loaded |
| `bundle/` | Vundle plugins (only `Vundle.vim` is tracked; others installed by `:PluginInstall`) |
| `tmp/` | Vim backup/swap/undo files (ignored) |

## Adding a vim plugin

Add `Plugin 'owner/repo'` between `vundle#begin()` and `vundle#end()` in `vimrc`,
then run `:PluginInstall`. Add the package to `Brewfile` if it needs a CLI tool.
