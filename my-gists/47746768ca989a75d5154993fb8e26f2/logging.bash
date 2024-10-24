#!/bin/bash

# Check if terminal is TTY.
# Source code inspired from https://unix.stackexchange.com/a/10065/436587 by Mikel.
#
# EXIT CODES
# ==========
# 0: The terminal is TTY.
# 1: The terminal is not TTY.
is_tty() {
  set +e
  ncolors=$(TERM="${TERM:-dumb}" tput colors)
  test -n "$ncolors" && test "$ncolors" -ge 8
  ec=$?
  set -e
  return $ec
}

# Echo the first argument only if the terminal is TTY. If not and a second
# argument is given, the second argument is printed.
#
# PARAMETERS
# ==========
# $1: The string to output only in TTY. If not in TTY, the string won't be
#     printed.
# $2: (Optional) The string to output if NOT in TTY. If the terminal is TTY,
#     the argument $1 is printed, and $2 is ignored. If not in TTY, $2 will
#     be printed if it is passed, or nothing is printed if only $1 is passed,
#
# OUTPUT
# ======
# stdout: The argument $1 or $2 depending on wether the terminal is TTY and if
#         $2 has been passe dor not.
# stderr: Argument error (see exit codes).
#
# EXIT CODES
# ==========
# 0: Success (regardless of TTY or not, and if one or two arguments have been
#    passed).
# 1: Argument error, zero arguments or more than two arguments have been given.
echo_tty() {
  if [[ $# == 0 || $# -gt 2 ]]; then
    echo "Error: Excepted 1 or 2 arguments, got $#." 2>&1
    return 1
  fi

  if is_tty; then
    echo -e "$1"
  elif [[ $# == 2 ]]; then
    echo -e "$2"
  fi
}

# Log the given string according in the given color if TTY.
#
# PARAMETERS
# ==========
#
# $1: The color code, like "32" for "\e[32m" (green) or "0;32" for "\e[0;32m"
#     (reset, then green).
# $*: The string to log. If not given, it is read from stdin.
_log_color() {
  pre=
  suf=
  # Check if TTY
  if is_tty; then
    pre="\e[$1m"
    suf="\e[0m"
  fi
  shift
  set -- "${1:-$(</dev/stdin)}" "${@:2}"
  echo -e "${pre}${*}${suf}"
}

# Log to the console really unimportant information.
#
# PARAMETERS
# ==========
#
# $*: The string to log. If not given, it is read from stdin.
log_finer() {
  set -- "${1:-$(</dev/stdin)}" "${@:2}"
  _log_color "1;30" "$*"
}

# Log to the console unimportant information.
#
# PARAMETERS
# ==========
#
# $*: The string to log. If not given, it is read from stdin.
log_fine() {
  set -- "${1:-$(</dev/stdin)}" "${@:2}"
  _log_color "1;35" "$*"
}

# Log to the console an information.
#
# PARAMETERS
# ==========
#
# $*: The string to log. If not given, it is read from stdin.
log_info() {
  set -- "${1:-$(</dev/stdin)}" "${@:2}"
  _log_color "0;34" "$*"
}

# Log to the console a valid message.
#
# PARAMETERS
# ==========
#
# $*: The string to log. If not given, it is read from stdin.
log_valid() {
  set -- "${1:-$(</dev/stdin)}" "${@:2}"
  _log_color "0;32" "$*"
}

# Log to the console a warning.
#
# PARAMETERS
# ==========
#
# $*: The string to log. If not given, it is read from stdin.
log_warning() {
  set -- "${1:-$(</dev/stdin)}" "${@:2}"
  _log_color "0;33" "$*" 1>&2
}

# Log to the console an error to standard error.
#
# PARAMETERS
# ==========
#
# $*: The string to log. If not given, it is read from stdin.
log_error() {
  set -- "${1:-$(</dev/stdin)}" "${@:2}"
  _log_color "0;31" "$*" 1>&2
}

# Log to the console a box with the given text inside.
#
# PARAMETERS
# ==========
# $1: The color of the box and text.
# $2: The right-top corner character.
# $3: The left-top corner character.
# $4: The left-bottom corner character.
# $5: The right-bottom corner character.
# $6: The horizontal bar character.
# $7: The vertical bar character.
# $*: The string to log.
#
# OUTPUT
# ======
# stdout: Print the box with its text.
log_box() {
  echo

  color=$1
  shift
  rt=$1
  shift
  lt=$1
  shift
  lb=$1
  shift
  rb=$1
  shift
  hz=$1
  shift
  vt=$1
  shift

  # Construct horizontal lines
  horizontal_lines=''
  horizontal_lines_length=0
  # Add two more for text whitespaces
  while [[ $horizontal_lines_length -lt $(( $(wc --chars <<< "$*") + 1)) ]]; do
    horizontal_lines="$horizontal_lines$hz"
    horizontal_lines_length=$(( horizontal_lines_length + 1 ))
  done

  _log_color "$color" "$rt$horizontal_lines$lt"
  _log_color "$color" "$(printf "$vt %s $vt" "$*")"
  _log_color "$color" "$rb$horizontal_lines$lb"
  echo
}

log_expanded_box() {
  term_width=$(/usr/bin/tput cols)
  text_width=$(wc --chars <<< "$8")

  text_lr_space=$(( ((term_width - text_width) / 2) - 2 ))

  log_box "${@:1:7}" "$(printf "%*s%s%*s" "$text_lr_space" ' ' "$8" "$text_lr_space" ' ')"
}

# Log to the console a simple box with the given text inside.
#
# PARAMETERS
# ==========
# $1: The color of the box and text.
# $*: The string to log. If not given, it is read from stdin.
#
# OUTPUT
# ======
# stdout: Print the simple box with its text.
log_simple_box() {
  log_box "$1" '┌' '┐' '┘' '└' '─' '│' "${*:2}"
}

# Log to the console a simple box with the given text inside, center-aligned.
#
# PARAMETERS
# ==========
# $1: The color of the box and text.
# $*: The string to log. If not given, it is read from stdin.
#
# OUTPUT
# ======
# stdout: Print the simple box with its text.
log_expanded_simple_box() {
  log_expanded_box "$1" '┌' '┐' '┘' '└' '─' '│' "${*:2}"
}

# Log to the console a double box with the given text inside.
#
# PARAMETERS
# ==========
# $1: The color of the box and text.
# $*: The string to log. If not given, it is read from stdin.
#
# OUTPUT
# ======
# stdout: Print the double box with its text.
log_double_box() {
  log_box "$1" '╔' '╗' '╝' '╚' '═' '║' "${*:2}"
}

# Log to the console a double box with the given text inside, center-aligned.
#
# PARAMETERS
# ==========
# $1: The color of the box and text.
# $*: The string to log. If not given, it is read from stdin.
#
# OUTPUT
# ======
# stdout: Print the double box with its text.
log_expanded_double_box() {
  log_expanded_box "$1" '╔' '╗' '╝' '╚' '═' '║' "${*:2}"
}

# Time the given command and parameter with the best found tool on the system.
#
# PARAMETERS
# ==========
# $0: Command to execute
# ${*:2}: Additionnal parameters to pass to the given command.
#
# ENVIRONMENT VARIABLE
# ====================
# time_fmt: The format of the time elapsed in standard output. Defaults to
#           'Time elapsed: ' (and then depends on the found tool).
#
# OUTPUT
# ======
# stdout: Same output as the command, followed by the time.
# stderr: Same output as the command.
#
# EXIT CODES
# ==========
# Same as command
ms_time() {
  if [[ -x /usr/bin/time ]]; then # Check if time tool is installed
    time_fmt="${time_fmt:-"Time elapsed: %E"}"
    /usr/bin/time -f "$time_fmt" "$@"
    return $?
  elif command -v time | grep -qPe '^time$'; then # built-in time tool
    time_fmt="${time_fmt:-"Time elapsed: %R"}"
    TIMEFORMAT="$time_fmt" time "$@"
    return $?
  else # manual
    start=$(date +%s)
    "$@"
    ec=$?
    end=$(date +%s)
    time_elapsed="$(( end - start ))"
    time_elapsed_fmt=$(date "-d@$time_elapsed" -u +%H:%M:%S)
    echo "Time elapsed: $time_elapsed_fmt"

    return $ec
  fi
}

export -f is_tty
export -f echo_tty
export -f _log_color
export -f log_finer
export -f log_fine
export -f log_info
export -f log_valid
export -f log_warning
export -f log_error
export -f log_box
export -f log_expanded_box
export -f log_simple_box
export -f log_expanded_simple_box
export -f log_double_box
export -f log_expanded_double_box
export -f ms_time
