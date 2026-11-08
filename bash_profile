# Login shells (macOS Terminal/iTerm) read this file, not ~/.bashrc.
# Everything lives in bashrc (including conda setup), so keep this minimal.
# Note: don't run `conda init bash` -- it would re-add a hardcoded block here.
[ -r ~/.bashrc ] && . ~/.bashrc
