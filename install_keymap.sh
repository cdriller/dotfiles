# Hardware Level remaps with udev([Tutorial](https://github.com/Alekamerlin/keyboard-remap-guide)):
sudo cp udev/90-remap.hwdb /etc/udev/hwdb.d/90-remap.hwdb
systemd-hwdb update
udevadm trigger

# Layer configuration with X11/xkb:
sudo cp xkb_symbols /usr/share/X11/xkb/symbols/de
setxkbmap de prilepp_ansi
