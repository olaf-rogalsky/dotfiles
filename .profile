# .profile should be posix-shell compliant, i.e. no fancy bash'isms.
#
# Login shells source $HOME/.profile after /etc/profile and
# /etc/profile.d/*.sh been sourced. Non-login bash
# shells source ~/.bashrc, instead.
#
# +-------------+-------+----------+---------+
# | interactive | login | .profile | .bashrc |
# +-------------+-------+----------+---------+
# | yes         | yes   | sourced  |         |
# | yes         | no    |          | sourced |
# | no          | yes   | sourced  |         |
# | no          | no    |          |         |
# +-------------+-------+----------+---------+

# I only add my $HOME/bin to $PATH. Any paths for interactive shells
# are added to .bashrc
export PATH="$HOME/bin:$PATH"

# xdg base directory environment variables:
#     The "XDG Base Directory Specification" defines a set of special
#     directories and corresponding environment bvariables. If these
#     variables are not defined, applications shall use default
#     values, instead. Unfortunately, not applicaions adhere to this
#     specification. Therefore its best, to set the variables to the
#     default values, anyway.

# There is a single base directory relative to which user-specific
# data files should be stored. If $XDG_DATA_HOME is either not set or
# empty, a default equal to $HOME/.local/share should be used.
export XDG_DATA_HOME="$HOME/.local/share"

# There is a set of preference ordered base directories relative to
# which data files should be searched. I added $HOME/local/share to
# the default value.
export XDG_DATA_DIRS="$HOME/local/share:/usr/local/share:/usr/share"

# There is a single base directory relative to which user-specific
# configuration files should be written.
export XDG_CONFIG_HOME="$HOME/.config"

# There is a set of preference ordered base directories relative to
# which configuration files should be searched.
export XDG_CONFIG_DIRS="/etc/xdg"

# There is a single base directory relative to which user-specific
# non-essential (cached) data should be written.
export XDG_CACHE_HOME="$HOME/.cache"

# There is a single base directory relative to which user-specific
# runtime files and other file objects should be placed.  This
# variable is set by pam_systemd(8).
# export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR-/run/user/$UID}"

# The $XDG_STATE_HOME contains state data that should persist between
# (application) restarts, but that is not important or portable enough
# to the user that it should be stored in $XDG_DATA_HOME. It may
# contain: actions history (logs, history, recently used files, …)
# current state of the application that can be reused on a restart
# (view, layout, open files, undo history, …)
export XDG_STATE_HOME="$HOME/.local/.state"

# Portals are the framework for securely accessing resources from
# outside an application sandbox. They provide a range of common
# features to applications, including: Determining network status,
# opening a file with a file chooser, opening URIs, taking screenshots
# and screencasts and so forth.  Applications can use portals to
# provide uniform access to features independent of desktops and
# toolkits. This is commonly used, for example, to allow screen
# sharing on Wayland via PipeWire, or to use file open and save
# dialogs on Firefox that use the same toolkit as your current desktop
# environment. Wezterm (and probably others, like chromium) use it to
# find out, wehter the current desktop has bright or dark appearance.
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP-gtk}" # use gtk as default

# some GTK applications (emacs) spit out error the following error
# messages
#     WARNING **: 22:10:03.191: AT-SPI: Could not obtain desktop path or name
#     WARNING **: 22:10:03.253: atk-bridge: GetRegisteredEvents returned message with unknown signature
#     WARNING **: 22:10:03.253: atk-bridge: get_device_events_reply: unknown signature
# Supposedly installing at-spi2-core should prevent those errors, but
# it actually doesn't do so.  ATK is the gnome accessability bus, used
# to access accessability hardware for disabled persons (think of
# screen readers).  I don't have any of those hardware, therefore the
# connection goes into nirvana -- hence the error.  The following
# setting prevents making such a connection.
export NO_AT_BRIDGE=1

# other variables
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export MATHEMATICA_HOME="/opt/Mathematica13.2.0"
export MATHEMATICA_BASE="/opt/Mathematica13.2.0" # $BaseDirectory is otherwise wrongly set
export BROWSER=vivaldi-stable
unset BROWSER # use xdg mechanisms, instead

# helper variable to prevent, that .profile is sourced twice or worse,
# infinte recursively
PROFILEREAD=true

# If this is an interactive, login bash shell, we source .bashrc
if [ "$BASH" != "" ]; then
    case "$-" in
        *i*) shopt -q login_shell && source "$HOME/.bashrc"
    esac
fi
