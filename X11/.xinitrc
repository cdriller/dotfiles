urxvtd -o -q -f
xrdb -merge ~/.config/X11/.Xresources
udiskie&
xinput set-button-map 9 1 2 3 5 4 6 7
exec i3
