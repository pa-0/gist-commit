#!/usr/bin/env zsh
# Download this script
# Save it somewhere. Make it an executable with
# $ chmod +x terminal.zsh
# Then add a systemwide shortcut for this script
# and you're done!
# Get the current window id
ACTIVE=$(xdotool getactivewindow)

# Find all the sublime text windows that are open.
# Remember to remove the "(UNREGISTERED)" part if you
# have it registered.
SUBLIMES=$(xdotool search --name "\\- Sublime Text \\(UNREGISTERED\\)")

# Find the ACTIVE window id in the SUBLIME window ids
if [[ $SUBLIMES =~ $ACTIVE ]] ; then
  # Use xdotool to send a keystroke to open the terminal in the
  # project folder. Use the Terminal package to configure a
  # hotkey. (https://packagecontrol.io/packages/Terminal)
  xdotool key --window "$ACTIVE" F1
  exit
fi

# I use urxvt as my terminal. Open your default terminal here.
exec ~/bin/urxvt.wrapper