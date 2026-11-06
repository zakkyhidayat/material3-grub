# material3-grub

A Material 3 theme for GRUB, with a generator script and an installer.

The theme is dark, uses a blue seed colour, and has M3 Expressive shapes in the background. It is built for a 1920x1200 panel.

## Contents

- `tools/grub/material3/`: the built theme (`theme.txt`, background, icons, menu fonts)
- `tools/grub/make_theme.py`: regenerates the theme from the colours and layout constants at the top of the file
- `tools/grub/install_grub.sh`: installs the theme and enables the graphical menu (dry run by default)
- `tools/grub/logos/`: source SVGs for the menu icons
- `docs/grub.md`: design notes, installer steps, and how to undo them

## Requirements

- Pillow (`python3-pillow`)
- `grub2-mkfont` and `rsvg-convert` (`librsvg2-tools`)
- Adwaita Sans fonts at `/usr/share/fonts/adwaita-sans-fonts/`
- Fedora's `grub2-tools` (the installer uses `grub2-mkconfig` and `grub2-editenv`)

## Install

Dry run first. It prints every command and changes nothing:

```bash
sh tools/grub/install_grub.sh
```

Then run it with `--run`. It asks before each step:

```bash
sudo sh tools/grub/install_grub.sh --run
```

The installer copies the theme to `/boot/grub2/themes/material3`, sets `GRUB_TERMINAL_OUTPUT`, `GRUB_GFXMODE` and `GRUB_THEME` in `/etc/default/grub`, shows the menu on every boot, and regenerates `grub.cfg`. The original `/etc/default/grub` is kept as `/etc/default/grub.before-material3`.

## Rebuild the theme

```bash
python3 tools/grub/make_theme.py          # writes tools/grub/material3/
sudo cp -r tools/grub/material3 /boot/grub2/themes/material3
```

Copying the files is enough. Run `grub2-mkconfig` again only if the font names change.

## Undo

```bash
sudo cp -p /etc/default/grub.before-material3 /etc/default/grub
sudo rm -r /boot/grub2/themes/material3
sudo grub2-editenv - set menu_auto_hide=1
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

## Notes

- The subtitle "ThinkPad X13 Gen 2i" is set in `make_theme.py`. Change it for other hardware.
- The Fedora icon is Fedora's logo, a trademark of its owner, used only as a menu icon.
