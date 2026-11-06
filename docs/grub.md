# Boot menu (GRUB, Material 3)

GRUB draws its menu in text mode by default, and some distros hide the menu while only one system is installed.
`tools/grub/install_grub.sh` switches GRUB to the graphical terminal, applies the `material3` theme, and shows the menu on every boot.

## The theme: `material3`
Made by `tools/grub/make_theme.py` (Pillow + `grub2-mkfont`) for a 1920x1200 panel:
- Material 3 dark scheme from a blue seed: surface `#111318`, a `surface-container` card with 40 px corners, the selected row
  as a `secondary-container` pill, icons on `primary` circles.
- M3 Expressive shapes in the background: a 12-lobe "cookie" (primary container) and an 8-lobe "flower" (tertiary container).
- Adwaita Sans: the title, subtitle and key hints are drawn into the background at real weights; menu labels (26 px) and the
  countdown (18 px) use GRUB fonts made from the same font (Latin and arrows only, to keep them small).
- Icons by GRUB class: `fedora` (the Fedora logo as it is, from `tools/grub/logos/fedora.svg`, from
  [Fedora icon (2021)](https://commons.wikimedia.org/wiki/File:Fedora_icon_(2021).svg), a trademark of its owner, used here
  only as a menu icon) and `efi`: a drawn settings gear.

GRUB draws a row's pixmap box *around* the row, padded by the corner images' size, so `item_height` is the visible row minus
twice the corner radius, every row gets a transparent box of the same size, and `item_spacing` makes up the rest.

The subtitle text ("ThinkPad X13 Gen 2i") is hard-coded in `make_theme.py`; change it there for other hardware.

## `tools/grub/install_grub.sh`
Dry run by default; `--run` asks before each step (`y` continues, anything else stops).

| Step | What |
|---|---|
| 1 | Copy the theme to `/boot/grub2/themes/material3` |
| 2 | `/etc/default/grub`: `GRUB_TERMINAL_OUTPUT="gfxterm"`, `GRUB_GFXMODE="1920x1200,auto"`, `GRUB_THEME=…/theme.txt`; the original is kept as `/etc/default/grub.before-material3` |
| 3 | `grub2-editenv - unset menu_auto_hide`: the menu shows on every boot |
| 4 | `grub2-mkconfig -o /boot/grub2/grub.cfg`, then checks the theme is in it |

## Changing it
Edit `make_theme.py` (colours in `C`, layout constants at the top), run it, then step 1 again (`sudo cp -r`); no
`grub2-mkconfig` needed unless the font names change.

## Undo
```sh
sudo cp -p /etc/default/grub.before-material3 /etc/default/grub
sudo rm -r /boot/grub2/themes/material3
sudo grub2-editenv - set menu_auto_hide=1
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
