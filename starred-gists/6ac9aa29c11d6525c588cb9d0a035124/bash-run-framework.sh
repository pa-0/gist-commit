#!/bin/bash
#
# (C) 2021, AG (github@mzpqnxow.com)
# BSD 3-Clause License
#
# Logging and tracing skeleton for Bash shell scripts
#
# Features
# --------
#   - Verbose execution tracing to stderr or to a file; optional, via start_trace()
#   - Full stacktrace on exception
#   - Simple logging wrapper
#
# Requirements
# ------------
#   - Bash >= 4.1
#   - The `jo` application (if you want JSON logging)
#
# Usage
# -----
#   - Set the CFG_* variables to on/off depending on what you want
#   - To use it, remove the test_fn1/test_fn2 functions and modify app() to call
#     your own functions
#
# WARNING
# -------
# ** Do NOT modify main(), it may screw up the stack frame logging; modify app() **
# 

# If you don't care about accessing unbound variables, non-zero exit codes, etc. then
# you can comment this out. It is recommended that you keep it, otherwise you will not
# benefit from the exception handling
set -Euo pipefail

# ----- BEGIN USER CONFIGURATION
# Log as JSON (requires the `jo` tool)
declare -g CFG_LOG_JSON=on
# Log the exception stacktrace as JSON also
declare -g CFG_LOG_STACKTRACE_JSON=off
# Set to `on` to see what an exception looks like
declare -g CFG_DEMO_EXCEPTION=on
# Include timestamps in log/trace messages
declare -g CFG_LOG_TIMESTAMPS=on
# Log additional context like function name and line in log()
declare -g CFG_LOG_CONTEXT=on
# Enable or disable tracing
declare -g CFG_TRACE=on
# Comment out to log to stderr
declare -g CFG_TRACE_OUTFILE="$(basename $0).$(date +%s).tracelog"
# Set to off to disable changing directory to the path of the script itself
declare -g CFG_CHANGE_DIR=on
# ----- END USER CONFIGURATION -----


# For optional tracing, these are lazily evaluated giving you extremely detailed information on
# every line traced. It's ugly to the human eye but useful for a *very* rich audit trail. You can
# modify this but only if you know what you're doing
declare -r PS4='(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[1]:-()} - [${SHLVL},${BASH_SUBSHELL}, $?]'
# Get the path of the script
declare -r CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"


# You need `jo` if you want JSON logging; I'm too lazy to printf in JSON format :>
if [ ${CFG_LOG_JSON:-off} == "on" ] && ! command -v jo &> /dev/null; then
  echo 'Please install the `jo` application or set CFG_LOG_JSON=off'
  exit 1
fi


# Change directory into it; optional, you can comment this out
[[ ${CFG_CHANGE_DIR:-off} == "on" ]] && cd "$CURDIR" || exit 1


# Call within main if wanted
configure_trace() {
  [[ ! -n "${CFG_TRACE_OUTFILE:-}" ]] && return
  echo "Script tracing to file is ENABLED"
  if [ -n $CFG_TRACE_OUTFILE ]; then
    # if [[ $(( ${BASH_VERSINFO[0]}*10 + ${BASH_VERSINFO[0]} )) -ge 41 ]]; then
    if [[ $(( BASH_VERSINFO[0]*10 + BASH_VERSINFO[0] )) -ge 41 ]]; then
      # Automatically get a file descriptor number if Bash >= 4.1
      exec {fd}>"$CFG_TRACE_OUTFILE"
      BASH_XTRACEFD=${fd}
    else
      # Pick an arbitrary but high file descriptor number if an older version of Bash
      # In theory, only 0/1/2 should be open, but in practice that's rarely the case
      # because of both FDs that may be inherited depending on how your script was started
      # and based on what else may be using descriptors in the script
      exec 500>"$CFG_TRACE_OUTFILE"
      BASH_XTRACEFD=500
    fi
  fi
}

# Call within main if wanted
start_trace() {
  set -x
}

log_text() {
  local status_msg=''
  if [ ${CFG_LOG_CONTEXT:-off} == "on" ]; then
    local idx=0
    for func in "${FUNCNAME[@]}"; do
      if [[ ! "$func" =~ log|sep|status|script_ctx|print_stack_trace ]]; then
        status_msg="$(printf $'%s()::%s' "${FUNCNAME[$((idx))]}" "${BASH_LINENO[$((idx - 1))]}")"
        break
      fi
      idx=$((idx + 1))
    done
  fi
  local timestamp="[$(date +'%Y-%m-%d %H:%M%Z')]"
  [ ${CFG_LOG_TIMESTAMPS:-off} == "on" ] && status_msg="$timestamp $status_msg" || status_msg="$status_msg"
  echo "$status_msg $*" >&2
}

log_json() {
  local funcname=''
  local status_msg=''
  local lineno=''
  if [ ${CFG_LOG_CONTEXT:-off} == "on" ]; then
    local idx=0
    for func in "${FUNCNAME[@]}"; do
      if [[ ! "$func" =~ log|sep|status|script_ctx|print_stack_trace ]]; then
        # status_msg="$(printf $'%s()::%s'  "${BASH_LINENO[$((idx - 1))]}")"
        funcname="function=${FUNCNAME[$((idx))]}"
        lineno="linenum=${BASH_LINENO[$((idx - 1))]}"
        break
      fi
      idx=$((idx + 1))
    done
  fi
  local timestamp="[$(date +'%Y-%m-%d %H:%M%Z')]"
  [ ${CFG_LOG_TIMESTAMPS:-off} == "on" ] && status_msg="$timestamp $status_msg" || status_msg="$status_msg"
  jo "funcname=$funcname" "lineno=$lineno" "message=$*" >&2
  # echo "$status_msg $*" >&2
}


log() {
  if [ ${CFG_LOG_JSON:-on} == "off" ]; then
    log_text "$@"
  else
    log_json "$@"
  fi
}


sep() {
  local char=${1:-"="}
  log "$(printf '%0.s'"$char" {1..80})"
}

line_break() {
  echo && echo
}

line() {
  echo
}

print_stack_trace() {
  local exit_code=$?
  [[ $exit_code -eq 0 ]] && return 0
  local idx=1
  local -i frameno=0
  local failed_cmd
  local failed_reason

  # faulting_fn="${FUNCNAME[$((idx))]}"
  # faulting_line="${BASH_LINENO[$((idx - 1))]}"

  if [[ $exit_code -gt 128 ]]; then
    failed_reason="FATAL SIGNAL IN CHILD"
  else
    failed_reason="NON-ZERO EXIT FROM COMMAND"
  fi

  failed_cmd="${BASH_COMMAND}"
  failed_cmd_msg="Failing command: $failed_cmd"
  failed_reason_msg="Failure reason:  $failed_reason"

  if [ "${CFG_LOG_STACKTRACE_JSON:-off}" == "on" ]; then
    log "$failed_cmd_msg"
    log "$failed_reason_msg"
  else
    printf "%s\n" "$failed_cmd_msg"
    printf "%s\n" "$failed_reason_msg"
  fi

  # for func in ${FUNCNAME[@]}; do
  for ((idx=1; idx < ${#FUNCNAME[@]}; idx += 1)); do
      
      if [ "${CFG_LOG_STACKTRACE_JSON:-off}" == "on" ]; then
        log_line=$(printf "#%-2d  %s %-4d @ %s()" $frameno "${BASH_SOURCE[$idx]}" ${BASH_LINENO[$((idx - 1))]} "${FUNCNAME[$((idx))]}")
        log "$log_line"
      else
        printf "#%-2d  %s %-4d @ %s()\\n" $frameno "${BASH_SOURCE[$idx]}" ${BASH_LINENO[$((idx - 1))]} "${FUNCNAME[$((idx))]}"
      fi
      frameno=$((frameno + 1))
  done

  trap - EXIT
  exit $exit_code
}

status() {
  sep && log "$1" && sep && line
}



# Test functions, to show the logging and tracing
test_fn2() {
    log "In function test_fn2, doing some stuff"
    if [ ${CFG_DEMO_EXCEPTION:-off} == "on" ]; then
      log "Triggering a fatal exception ..."
      false
    fi
    log "Returning from test_fn2!"
}

# Test function, replace with your own script logic
test_fn1() {
    log "In function test_fn1, doing some stuff"
    test_fn2
    log "All set, test_fn1 is done ..."
}


app() {
    log "Starting app logic"
    test_fn1
    log "Completing app logic"
    return 0
}


# Follow this model, keep the trace calls here (or comment them out) and put
# your script logic inside of app()
entry_point() {
  configure_trace
  if [ "${CFG_TRACE:-on}" == "on" ]; then
    echo start trace
    start_trace
  fi
  app
  return $?
}

cleanup() {
  local exit_code=$?
  log "Cleaning up, exiting on exit_code=$exit_code ..."
  log "Done"
}


trap 'print_stack_trace' ERR EXIT 
entry_point "$@"
exit $?
