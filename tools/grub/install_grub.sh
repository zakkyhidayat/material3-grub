#!/bin/sh
# Installs the material3 Material 3 theme as the GRUB boot menu:
#   1. theme to /boot/grub2/themes/material3 (made by tools/grub/make_theme.py)
#   2. /etc/default/grub: graphical terminal at 1920x1200 with the theme (the original is kept as grub.before-material3)
#   3. show the menu on every boot (some distros hide it while only one system is installed: menu_auto_hide)
#   4. regenerate /boot/grub2/grub.cfg and check it
#
#   sh tools/grub/install_grub.sh          dry run: shows every command, changes nothing
#   sh tools/grub/install_grub.sh --run    does it, asking before each step
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
THEME=$HERE/material3 DEST=/boot/grub2/themes/material3

RUN=; [ "$1" = --run ] && RUN=1
die() { echo "install_grub: $*" >&2; exit 1; }
step() {
  echo; echo "== $1"; shift; echo "   \$ $*"
  [ -n "$RUN" ] || return 0
  printf '   run this step? [y/n] '; read a; case "$a" in y|Y|yes) ;; *) false;; esac || die "stopped before: $*"
  "$@"
}

[ -f "$THEME/theme.txt" ] || die "no theme: run python3 tools/grub/make_theme.py first"
command -v grub2-mkconfig >/dev/null || die "grub2-mkconfig not found (Fedora's grub2-tools)"

set_key() {  # set_key KEY VALUE in /etc/default/grub
  if grep -q "^$1=" /etc/default/grub; then sudo sed -i "s|^$1=.*|$1=\"$2\"|" /etc/default/grub
  else echo "$1=\"$2\"" | sudo tee -a /etc/default/grub >/dev/null; fi
}

[ -n "$RUN" ] || echo "(dry run: nothing is changed; --run to do it)"

step "1/4 install the theme" \
  sh -c "sudo rm -rf '$DEST' && sudo mkdir -p /boot/grub2/themes && sudo cp -r '$THEME' '$DEST' && sudo ls '$DEST' | tr '\n' ' ' && echo"
if [ -n "$RUN" ]; then
  echo; echo "== 2/4 /etc/default/grub: GRUB_TERMINAL_OUTPUT=gfxterm, GRUB_GFXMODE=1920x1200,auto, GRUB_THEME=$DEST/theme.txt"
  printf '   run this step? [y/n] '; read a; case "$a" in y|Y|yes) ;; *) false;; esac || die "stopped at step 2"
  sudo test -f /etc/default/grub.before-material3 || sudo cp -p /etc/default/grub /etc/default/grub.before-material3
  set_key GRUB_TERMINAL_OUTPUT gfxterm; set_key GRUB_GFXMODE 1920x1200,auto; set_key GRUB_THEME "$DEST/theme.txt"
  grep -E '^GRUB_(TERMINAL_OUTPUT|GFXMODE|THEME|TIMEOUT)=' /etc/default/grub | sed 's/^/   /'
else
  echo; echo "== 2/4 /etc/default/grub: GRUB_TERMINAL_OUTPUT=gfxterm, GRUB_GFXMODE=1920x1200,auto, GRUB_THEME=$DEST/theme.txt (backup: /etc/default/grub.before-material3)"
fi
step "3/4 show the menu on every boot" sudo grub2-editenv - unset menu_auto_hide
step "4/4 regenerate /boot/grub2/grub.cfg and check it" \
  sh -c "sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>&1 | tail -3 && sudo grep -q 'material3/theme.txt' /boot/grub2/grub.cfg && echo '   grub.cfg has the theme'"
[ -n "$RUN" ] && echo && echo "Done. The theme is active from the next boot."
:
