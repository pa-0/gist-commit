# 🧙✨ Secret Bash Magic Spellbook 🔮🪄🌟

This gist contains useful Bash spells that I acquired.

<!-- TODO: pdf commands, necat server (https://stackoverflow.com/questions/16640054/minimal-web-server-using-netcat), PS4 for debug, how to discover devices on local network -->

**Table of Contents:**

- [General](#general)
  - [⛔ Script exits at first error](#-script-exits-at-first-error)
  - [🐛 Debugging a Bash script](#-debugging-a-bash-script)
  - [📨 Parse arguments](#-parse-arguments)
  - [📝 Pass arguments or read from `stdin`](#-pass-arguments-or-read-from-stdin)
  - [💂 Check if root](#-check-if-root)
  - [⏩ Manage script's redirection](#-manage-scripts-redirection)
  - [⏳ Flush filesystem changes](#-flush-filesystem-changes)
  - [🔍 Check array contains item](#-check-array-contains-item)
  - [🔠 Change text case](#-change-text-case)
  - [💣 Join array into a string](#-join-array-into-a-string)
  - [💥 Split string into array](#-split-string-into-array)
  - [🥅 Multiple traps](#-multiple-traps)
  - [🔁 Loop over a JSON list](#-loop-over-a-json-list)
  - [➿ Parse files and folders with `find`](#-parse-files-and-folders-with-find)
  - [➰ Iterate over character-separated string](#-iterate-over-character-separated-string)
  - [⬇️ Get public IP address](#%EF%B8%8F-get-public-ip-address)
  - [🔏 Encrypt/Decrypt a file/folder](#-encryptdecrypt-a-filefolder)
  - [👇 Source a bash file in the same location of the script](#-source-a-bash-file-in-the-same-location-of-the-script)
  - [🔒 Locking file](#-locking-file)
  - [💽 See disk usage](#-see-disk-usage)
  - [⬇ Import all aliases in non-interactive shell](#-import-all-aliases-in-non-interactive-shell)
  - [🔗 Extract hostname from simple URL](#-extract-hostname-from-simple-url)
  - [▶ Add prefix to all lines from `stdout` and `stderr` of a command](#-add-prefix-to-all-lines-from-stdout-and-stderr-of-a-command)
  - [📃 Save lines from stdout to an array](#-save-lines-from-stdout-to-an-array)
  - [📩 Add lines to a file after a regex](#-add-lines-to-a-file-after-a-regex)
  - [⏩ Command completion from history](#-command-completion-from-history)
- [Docker](#docker)
  - [🐳 Execute a command from the host in the container](#-execute-a-command-from-the-host-in-the-container)
  - [🐳 Dependency-based Docker tag hash](#-dependency-based-docker-tag-hash)
- [Git](#git)
  - [◀ Revert a commit without creating a commit](#-revert-a-commit-without-creating-a-commit)
  - [🌿 Create a disconnected branch from default code](#-create-a-disconnected-branch-from-default-code)
- [SSH](#ssh)
  - [⌚ Synchronize date with SSH](#-synchronize-date-with-ssh)
  - [🛑 Escape a SSH session](#-escape-a-ssh-session)
  - [🐱‍👤 Execute SSH Agent at startup](#-execute-ssh-agent-at-startup)
  - [🧦 Create SSH socket](#-create-ssh-socket)
- [WSL](#wsl)
  - [📋 Use Windows Clipboard](#-use-windows-clipboard)
  - [🔊 Play beep from WSL](#-play-beep-from-wsl)
  - [⏳ Start `cron` daemon at Windows startup](#-start-cron-daemon-at-windows-startup)
  - [🐳 Install Docker engine in WSL](#-install-docker-engine-in-wsl)
  - [🐳 Start `dockerd` daemon at Windows startup](#-start-dockerd-daemon-at-windows-startup)

## General

### ⛔ Script exits at first error

In Bash, you can put the following line at the top of your script, after the shebang:

```bash
set -euo pipefail
```

**Explanation:**

- **`-e`:** If a command fail, then the script stops and fail too. This avoid the script to continue when critical commands are failing (like `cd`). The commands in `until`, `while`, `for`, `if` and `elsif`, but also the commands that are in a `&&` or `||` expression are ignored, so conditions can still work.
- **`-u`:** If shell encounters an undefined variable, the script will crash. Useful when the variables must be considered mandatory. Empty variable are not considered as undefined.
- **`-o`:** Set a specific option on for this shell session. In this case, the option `pipefail` will cause the script to fail if a pipe command fails (like `/bin/false | cat`).

_Source:_ [Bash Reference Manual - The Set Builtin](https://www.gnu.org/software/bash/manual/bash.html#index-set)

### 🐛 Debugging a Bash script

Debugging a Bash script is hard without a good debugger, and `echo` commands can be a lot!
So, in order to debug a Bash script quickly, please consider using the following spell that will output to the standard error every commands (after shell expansion) before execution:

```bash
PS4='+[${FUNCNAME[0]:-main}]${BASH_SOURCE[0]:-}:$LINENO> '
set -x
```

This will print all commands with the expanded prefix defined by `PS4`, that will indicate the current function from the stack (or default to `main`), the file that is being executed (useful if your script calls other sub-scripts) and the current line of the command.
If you want to encapsulate your debugging code, you can _close_ this debugging session with the following counter-spell:

```bash
{ set +x; } 2> /dev/null
```

The command `set +x` will remove the debugging property, but because we don't want it to be shown to the console (because it is superfluous), we encapsulate it under a sub-shell command (with `{}`) and redirect the standard error to `null`, so it is not displayed.
The general command will not be outputed because when the shell would want to, `set +x` will already have stopped the debugging session.

In order to get better error message, you can also trap errors!
See [how to catch multiple traps](#-multiple-traps) to learn how to efficiently trap them!

Happy catching!

### 📨 Parse arguments

**Parameters:**

The following snippet shows how to parse arguments from the command line with long and short option, with or without the equal sign:

```bash
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      print_help
      exit 0
      ;;
    --hostname=*)
      SRV_ADDR="${1#*=}"
      shift
      ;;
    --hostname)
      shift
      SRV_ADDR="$1"
      shift
      ;;
    --port=*)
      SRV_PORT="${1#*=}"
      shift
      ;;
    --port|-p)
      shift
      SRV_PORT="$1"
      shift
      ;;
    *)
      echo "Unknown argument: $1" 1>&2
      print_help 1>&2
      exit 1
      ;;
  esac
done
```

**Parameters with files:**

If you want the user to provide one or multiple files after specifying arguments, use the following snippet:

```bash
files=()
# Tell if the script must process arguments or files. It starts y processing
# arguments (true).
process_args='true'
while [ $# -gt 0 ]; do
  if [[ $process_args = 'false' ]]; then
    files+=("$1")
    shift
  else
    case "$1" in
      --help|-h)
        print_help
        exit 0
        ;;
      --hostname=*)
        SRV_ADDR="${1#*=}"
        shift
        ;;
      --hostname)
        shift
        SRV_ADDR="$1"
        shift
        ;;
      --port=*)
        SRV_PORT="${1#*=}"
        shift
        ;;
      --port|-p)
        shift
        SRV_PORT="$1"
        shift
        ;;
      --)
        shift
        process_args='false'
        ;;
      -*)
        echo "Unknown argument: $1" 1>&2
        print_help 1>&2
        exit 1
        ;;
      *)
        process_args='false'
        files+=("$1")
        shift
        ;;
    esac
  fi
done
```

### 📝 Pass arguments or read from `stdin`

In a bash script or function, sometimes you want to recieve an argument, or if nothing is passed, read it from `stdin`.
The following spell will help you achieve this:

```bash
set -- "${1:-$(</dev/stdin)}" "${@:2}"
```

### 💂 Check if root

To check if a script is being executed as root, use the following spell:

```bash
if [ "$EUID" -ne 0 ]; then
  echo "This script needs to be run as root." 1>&2
  exit 1
fi
```

### ⏩ Manage script's redirection

If you want you script to automatically redirect all its own `stdout` and `stderr` output to a file, or a process, without changing the invocation of your script using a pipe, you can use the following spell:

```bash
exec 1> >(tee -a "$LOG_FILE") 2> >(tee -a "$LOG_FILE" 1>&2)
```

In this spell, both `stdout` and `stderr` will still be printed to the console, but also to an external file, so you can log your script's output.

Here's a more generic spell to write your script's output to a file and the console, without saving the colors:

```bash
# Function to use when redirecting stdout and stderr to a file and the console
_redirect() {
  tee >(sed -r "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g" | tee -a bug.log > /dev/null)
}

# Redirect all stdout and stderr to a file
exec 1> >(_redirect) 2> >(_redirect 1>&2)
```

To undo this action, you need to adapt it to save the default output and error first:

```bash
exec 3>&1 4>&2
exec 1> >(tee -a "$LOG_FILE") 2> >(tee -a "$LOG_FILE" 1>&2)

# ...

# Undo redirection
exec 1>&3 2>&4
```

### ⏳ Flush filesystem changes

> :warning: WARNING!
>
> The following is considered **dark magic** and should be used with caution.

Sometimes, you will perform an operation on the filesystem, and then immediately after, you make an operation on those new changes, and the last command fails, reporting that the first changes you made are not there.
This very strange bug happens in script, when two commands are executing sequentially very quickly.

To solve this, you can separate those two commands with `sleep 0`.

It basically tricks the scheduler to re-task your Bash script immediately after. But the real magic is that it also flushes the I/O queue.

Source: https://stackoverflow.com/a/7577647

### 🔍 Check array contains item

The following function will search 

```bash
# Check if a bash array contains the given item.
#
# PARAMETERS
# ==========
# $1: The element to search in the array.
# $*: The array items. You can pass it as "${my_array[@]}" (with double quotes).
#
# RETURN CODES
# ============
# 0: The item is in the array.
# 1: The item was not found in the array.
array_contains() {
  local seeking=$1; shift
  local in=1
  for element; do
    if [[ $element == "$seeking" ]]; then
      in=0
      break
    fi
  done
  return $in
}

arr=(a b c "d e" f g)
array_contains "a b" "${arr[@]}" && echo yes || echo no    # no
array_contains "d e" "${arr[@]}" && echo yes || echo no    # yes
```

If you want to only pass the array name instead of its values:

```bash
# Check if a bash array contains the given item.
#
# PARAMETERS
# ==========
# $1: The name of the array. It will be expanded using the ${!parameter}
#     indirection.
# $2: The element to search in the array.
#
# RETURN CODES
# ============
# 0: The item is in the array.
# 1: The item was not found in the array.
array_contains() {
  local array="$1[@]"
  local seeking=$2
  local in=1
  for element in "${!array}"; do
    if [[ $element == "$seeking" ]]; then
      in=0
      break
    fi
  done
  return $in
}

# shellcheck disable=SC2034
arr=(a b c "d e" f g)
array_contains arr "a b" && echo yes || echo no    # no
array_contains arr "d e" && echo yes || echo no    # yes
```

_Source:_ [StackOverflow](https://stackoverflow.com/a/14367368)

### 🔠 Change text case

In Bash v4+, you can use the following spells:

**To uppercase:**

```bash
$ foo="bar BAR"
$ awk '{print toupper($0);}' <<< "$foo"
BAR BAR
```

_Source_: https://www.w3schools.io/terminal/bash-string-uppercase/

**To lowercase:**

```bash
$ foo="baR BAR"
$ awk '{print tolower($0);}' <<< "$foo"
bar bar
```

_Source_: https://www.w3schools.io/terminal/bash-string-uppercase/

**Capitalize the first letter of a string:**

```bash
$ foo="bar bar"
$ echo "${foo^}"
Bar bar
```

_Source:_ https://stackoverflow.com/a/12487455

### 💣 Join array into a string

To join a bash array into a string, use the following spell:

```bash
cities=(Paris "New York" Madrid)
itinerary=$(IFS=, ; echo "${cities[*]}")
echo "My itinerary: $itinerary"
```

> ⚠ Note that IFS only accepts one character, it cannot support `", "` for example.

_Source:_ https://stackoverflow.com/a/9429887

### 💥 Split string into array

To split a string into a bash array, you can use this spell:

```bash
cities="Paris,Madrid,Rome"
IFS=',' read -ra array <<< "$cities"
echo "The first city to visit is ${array[0]}"
```

_Source:_ https://stackoverflow.com/a/10586169

### 🥅 Multiple traps

The following variable and function create a stack for each used signal, so you can add multiple trap to the same signal:

```bash
# Associative arrays, the keys are the signal and the values the traps
declare -A _trap_stack

# Function to add a trap with a specific signal.
#
# PARAMETERS
# ==========
# $1: The trap to add. If '-' is given, the stack associated to the given signal
#     is reseted by calling `trap - $2`.
# $2: The signal.
add_trap() {
  if [[ -z "${_trap_stack["$2"]:-}" ]]; then
    _trap_stack["$2"]="$1"
  else
    _trap_stack["$2"]="${_trap_stack["$2"]}; $1"
  fi

  # shellcheck disable=SC2064
  trap "${_trap_stack["$2"]}" "$2"
}
```

Example:

```bash
add_trap 'touch err1.txt' ERR
add_trap 'touch err2.txt' ERR

add_trap 'touch file1.txt' EXIT
add_trap 'touch file2.txt' EXIT
```

> **⚠ WARNING:**
> Do NOT mix named and integer signals, they will overwrite each other.

To trap any eror and print as many information as possible about it:

```bash
# Trap errors to print as much information as possible
# shellcheck disable=SC2016
add_trap 'echo "Error: The error code $? was returned in ${BASH_SOURCE[0]} line ${LINENO} and in function \"${FUNCNAME[0]:-main}\" when executing \"${BASH_COMMAND}\"." 1>&2' ERR
```

### 🔁 Loop over a JSON list

Welcome to `bash.js`:

```bash
my_json='["a", "b", "c"]'
my_array=()

while IFS=$'\n' read -r item; do
  echo "Adding $item to my_array..."
  my_array+=("$item")
done < <(jq -Mrc '.[]' <<< "$my_json")

echo "My array:"
echo "${my_array[@]}"
```

To avoid any subprocess from consuming your shell input, one can use file descriptor:

```bash
exec 3< <(jq -Mrc '.[]' <<< "$my_json")
while IFS=$'\n' read -r item <&3; do
  my_command "$item"
done

# Close file descriptor
exec 3<&-
```

If you want to convert a JSON list to a Bash array in Bash, you can also use this trick:

```bash
readarray -d $'\n' -t my_array <<< "$(jq -Mrc '.[]' <<< "$my_json")"
```

### ➿ Parse files and folders with `find`

If you want to use a loop on `find` results, use the following spell:

```bash
while IFS= read -rd '' file
do
  echo "Playing file $file."
done < <(find mydir -mtime -7 -name '*.mp3' -print0)
```

### ➰ Iterate over character-separated string

If you have a comma-separated list of item in a variable, you can loop over it by using Bash substitution:

```bash
list=abc,def,ghi

for item in ${list//,/ }; do
  echo "$item"
done
```

_Source:_ https://stackoverflow.com/a/35894538/7347145

### ⬇️ Get public IP address

To get the public IP address, use the following spell:

```bash
curl -fsSL https://ipinfo.io/ip
```

To save it in a variable:

```bash
my_ip=$(curl -fsSL https://ipinfo.io/ip 2> /dev/null | tr -d '\n')
```

_Source:_ [Linux Config](https://linuxconfig.org/how-to-use-curl-to-get-public-ip-address)

### 🔏 Encrypt/Decrypt a file/folder

To encrypt and decrypt a file using GPG:

```bash
gpg --output encrypted.data --symmetric --cipher-algo AES256 un_encrypted.data
gpg --output un_encrypted.data --decrypt encrypted.data
```

To encrypt and decrypt multiple files and/or folder(s), zip them in a `.tar` file before:

```bash
# Zip
tar czf myfiles.tar.gz file1 file2 mydirectory/
# Encrypt
gpg --output myfiles.tar.gz.enc --symmetric --cipher-algo AES256 myfiles.tar.gz

# Decrypt
gpg --output myfiles.tar.gz --decrypt myfiles.tar.gz.enc
# Unzip
tar xzf myfiles.tar.gz
```

_For more information, see [this gist](https://gist.github.com/Cynnexis/f39a2360d09bc17f74c2ad35be58fcc9)_.

### 👇 Source a bash file in the same location of the script

```bash
source "$(dirname "$0")/my_deps.bash"
```

### 🔒 Locking file

This snippet allows your script to have a unique run, and avoid two execution of the same script, with a fancy error message.

```bash
# Locking file
LOCK_FILE_PATH="/var/tmp/$(basename $0).lock"
if [[ -f $LOCK_FILE_PATH ]]; then
  set +eu
  user=$(yq -r '.user' < "$LOCK_FILE_PATH")
  uid=$(yq -r '.uid' < "$LOCK_FILE_PATH")
  info=$(yq -r '.info' < "$LOCK_FILE_PATH")
  date_iso8601=$(yq -r '.date.iso8601' < "$LOCK_FILE_PATH")
  date_now=$(date +%s)
  date_then=$(yq -r '.date.unix_epoch_s' < "$LOCK_FILE_PATH")
  timedelta=$(( date_now - date_then ))
  echo -e "ERROR: It looks like the script is already being run by $user($uid) $info.\nThis run started at $date_iso8601 ($(date "-d@$timedelta" -u +%H:%M:%S) from now).\nIf you think this is a mistake, you can remove the lock file at \"$LOCK_FILE_PATH\"." 1>&2
  exit 1
fi

# Trap EXIT to remove the lock file
trap 'rm -f "$LOCK_FILE_PATH"' EXIT

# Write the lock file (YAML syntax)
cat <<EOF > "$LOCK_FILE_PATH"
---
# Lock file for $0.
user: "$USER"
uid: $UID
info: "$USER_INFO"
date:
  unix_epoch_s: $(date +%s)
  iso8601: "$(date '+%FT%T')"
EOF
```

### 💽 See disk usage

This section will teach you useful spells to analyze the space of your computer and invidual folders with their sub-directories.

#### Disk

To list the avaialble space on each file systems, use the [`df(1)`](https://linux.die.net/man/1/df) spell:

```bash
df -h
```

#### Folders

To analyze the spaces taken by the files by summing them by directories, use the [`du(1)`](https://linux.die.net/man/1/du) spell:

```bash
du -csh *
```

This will comptue the totla size of all folders in the current direcotyr, and display a summary of the total space.

#### Big files

You can search for big files using the following commands:

```bash
sudo find /bin /sbin /usr /etc /home /opt /root /var/log -type f -size +10M
```

To search for duplciated filed using [`fdupes(1)`](https://linux.die.net/man/1/fdupes):

```bash
sudo fdupes -r /bin /sbin /usr /etc /home /opt /root /var/log
```

#### Optimize disk

Remove useless packages from APT:

```bash
sudo apt-get autoremove
```

Free some logs:

```bash
sudo journalctl --disk-usage
sudo journalctl --vacuum-time=3d
```

_Source:_ https://itsfoss.com/free-up-space-ubuntu-linux/

You can also clean up the temporary files using the following spell:

```bash
find /tmp -mtime +7 -and -not -exec fuser -s {} \; -and -exec rm -rf {} \;
```

_Source:_ [Super User](https://superuser.com/a/499053)

### ⬇ Import all aliases in non-interactive shell

In non-interactive environment, such as specific bash scripts, you cannot use aliases, which is a shame when you want to cast some overly-complicated spells.
The following snippet allows you to load them back in a bash script with some `shopt` magic and parsing:

```bash
shopt -s expand_aliases
# ... or pass "-O expand_aliases" to the bash invocation

while read -r line; do
  eval \$line
done < <(grep -Pe '^\s*alias\s+' ~/.bashrc)

eval my_alias
```

### 🔗 Extract hostname from simple URL

```bash
url=https://my.example.com/
hostname="${url/#http:\/\//}"
hostname="${hostname/#https:\/\//}"
hostname="${hostname/%\//}"
```

### ▶ Add prefix to all lines from `stdout` and `stderr` of a command

If you want to prefix all the outputed lines of a command to the console, use the following pipe:

```bash
LOG_FILE="$(date +%F-%Hh%Mm%Ss)_my_command.log"
my_command |& tee -a "$LOG_FILE" | stdbuf -o0 sed 's@^@my_prefix> @'; echo "my_command exited with status ${PIPESTATUS[0]}." | tee -a "$LOG_FILE"; }
```

### 📃 Save lines from stdout to an array

```bash
IFS=$'\n' lines=($(head -n10 my_file.txt))

echo "${#lines[@]}" # 10
```

### 📩 Add lines to a file after a regex

```bash
sed '/my_regex/r add.txt' file.txt
```

with `add.txt`:

```plain
new line 1
new line 2
new line 3
```

and `file.txt`:

```plain
My file
my_regex
Final line
```

Results:

```plain
My file
my_regex
new line 1
new line 2
new line 3
Final line
```

_Source:_ https://stackoverflow.com/a/22497499

### ⏩ Command completion from history

In Bash, to re-execute a command you already launched with the beginning of it, you can type `Ctrl`+`R` to search through the history. One way to do it easier like in Zsh is to add the following content to your `~/.inputrc`:

```bash
# Key bindings, up/down arrow searches through history
"\e[A": history-search-backward
"\e[B": history-search-forward
"\eOA": history-search-backward
"\eOB": history-search-forward
```

You can then load the configuration with: `bind -f ~/.inputrc`

_Source:_ https://unix.stackexchange.com/a/20830

## Docker

### 🐳 Execute a command from the host in the container

If you have a binary on your host that you would like to run in the container, you can use the following spell:

1. Get the PID of the container:
    ```bash
    docker inspect --format '{{.State.Pid}}' <container>
    ```
2. Execute your command using [`nsenter(1)`](https://www.man7.org/linux/man-pages/man1/nsenter.1.html):
    ```bash
    nsenter -t <pid> -n <command>
    ```

### 🐳 Dependency-based Docker tag hash

If you want to have a script that automatically build your Dockerfile if the image is missing or some critical files have changed, but without re-building it every time you use it, here the solution:

You can hash the content of those critical files and build arguments and put them in the tag part of the image name.

```bash
tag="$(echo "author=$UID" \
  | cat - "Dockerfile" "entry-point.sh" \
  | sha256sum \
  | awk '{print $1;}')"

docker build -t "my_image:$tag" --build-arg "author=$UID" .
```

## Git

### ◀ Revert a commit without creating a commit

Sometimes, we'd like to revert some changes from a previous commit without generate a reverse-commit. One can use `git revert --no-commit`, but it will stage the file. In order to revert a commit changes without staging them, here a pipe spell you can cast:

```bash
git show <rev> | git apply -R
```

_Source:_ [StackOverflow](https://stackoverflow.com/a/33676571)

### 🌿 Create a disconnected branch from default code

If you want to create a branch that is completely empty, without any link with previous commits or refs, you can use the following spells:

```bash
git checkout --orphan my-branch
git rm -rf .
# <add files>
git add $files
git commit -m 'Initial commit for my-branch'
```

This is useful when you want to seperate your code from your documentation for example.

_Source:_ https://stackoverflow.com/a/5690048/7347145

## SSH

### ⌚ Synchronize date with SSH

**Send date to server:**

```bash
ssh -t $remote_server sudo date -s "@$(date -u +"%s")"
```

_Source:_ https://www.commandlinefu.com/commands/view/14135/synchronize-date-and-time-with-a-server-over-ssh

**Get date from server:**

```bash
sudo date "--set=$(ssh $remote_server date)"
```

_Source:_ https://unix.stackexchange.com/a/218917/436587

### 🛑 Escape a SSH session

If you want to quickly evade an SSH session or it's frozen, and you can get away, you can use the following key shortcut to kill it: `Enter`+`~`+`.`

_Source:_ https://stackoverflow.com/a/28981113/7347145

### 🐱‍👤 Execute SSH Agent at startup

To execute the SSH agent when you login, you can add the following snippet to your `~/.bashrc`, `~/.bash_profile` or to a system profile script like `/etc/profile.d/ssh-agent.sh`:

```bash
# Launch ssh-agent at startup.
# Source code inspired from:
# * https://unix.stackexchange.com/a/132117
# * https://code.visualstudio.com/docs/remote/troubleshooting#_setting-up-the-ssh-agent

if [ -z "$SSH_AUTH_SOCK" ]; then
  # Check for a currently running instance of the agent
  running_agent="$(ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]')"
  if [ "$running_agent" = "0" || ! -f /tmp/ssh-agent.sh ]; then
    ssh-agent -s < /dev/null 2> /dev/null > /tmp/ssh-agent.sh
    chmod +x /tmp/ssh-agent.sh
  fi
  source /tmp/ssh-agent.sh > /dev/null
fi
```

_Source:_
- https://unix.stackexchange.com/a/132117
- https://code.visualstudio.com/docs/remote/troubleshooting#_setting-up-the-ssh-agent

### 🧦 Create SSH socket

You can create your own socket on your local filesystem to allow applications to communicate with remote server through SSH.
This can be done by casting the following spell:

```bash
ssh -fnNTL /path/to/local/socket:localhost:22 user@server.com
```

**Explanation:**

- `-f`: Go to background just before command execution.
- `-n`: Prevents reading from stdin.
- `-N`: Do not execute a remote command, just forward the connection.
- `-T`: Disable pseudo-tty allocation.
- `-L`: Forward local port to remote socket, with the format `[bind_address:]port:host:hostport`.

## WSL

### 📋 Use Windows Clipboard

You can use the Windows clipboard system in the WSL to perform copy-paste operations.
The following instructions will show you how to cast some `ctrl+c`/`ctrl+v` spells inside a WSL terminal:

**Copy:**

```bash
cat my_clipboard.txt | clip.exe
my_command |& clip.exe
```

**Paste:**

```bash
powershell.exe -c Get-Clipboard > my_clipboard.txt
powershell.exe -c Get-Clipboard | my_command
```

_Source:_ [SuperUser](https://superuser.com/a/1618544)

### 🔊 Play beep from WSL

The WSL cannot play any sounds because it is not connected to any audio interface.
However, you can trick it to play a sound by calling `powershell.exe` and use the built-in `beep` function.
In a WSL console, cast the following spell:

```bash
powershell.exe "[console]::beep(500,300)"
```

The first argument defines the pitch (must be between 190 and 8500 to be heard), and the second argument is the duration in milliseconds.

You can also set it as a function to be more confortable:

```bash
pbeep () {
  timeout 5s powershell.exe "[console]::beep(${1:-500},${2:-300})"
}
```

_Source:_ [Microsoft Dev Blogs](https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-send-beep-to-console/)

### ⏳ Start `cron` daemon at Windows startup

In WSL, configure sudo by executing `sudo visudo` and adding the following line:

```bash
# Allow anyone to start the cron daemon
%sudo ALL=NOPASSWD: /etc/init.d/cron start
```

In Windows, open the applications menu with `Super` and search for WSL. Right-click on the icon to select "_Open file location_".
In the explorer, right-click on the `wsl.exe` file and select "_Copy_".
Close the explorer.

Then, use the shortcut `Super`+`R` and type `shell:startup` in the dialog box.
It will open the folder containing all softwares and script to execute at startup.
Right-click and select "_Past shortcut_".
Open the properties of the shortcut, and add the following argument in the target, after the location of the executable file: `sudo /etc/init.d/cron start`

The target should look something like:

```bash
"C:\Program Files\WindowsApps\wsl.exe" sudo /etc/init.d/cron start
```

_Source:_ https://blog.snowme34.com/post/schedule-tasks-using-crontab-on-windows-10-with-wsl/index.html

### 🐳 Install Docker engine in WSL

First, uninstall Docker Desktop for Windows by going to **Settings > Apps**, type "Docker" in the search bar and then click on "Uninstall".

#### Install WSL

Then, make sure you have WSL installed (you can use the MS-DOS command `wsl -l -v`). If not, follow those steps:
1. Download Ubuntu from the Microsoft Store.
2. Open a terminal by typing "Cmd" in the Windows search bar, and enter the following command: `wsl -l -v`
   You should see something like this (make sure the version is 2):
   ```bash
     NAME      STATE           VERSION

   * Ubuntu    Running         2
   ```
   If you see multiple images, you can set a default one by typing `wsl set default <Name>` (with `<Name>` being the name (first column) of the image, like "`Ubuntu`").
3. You can now set up a user in the WSL you just installed by typing `wsl` or opening the WSL terminal from the Windows search bar.
4. If you encountered a problem at some point, please read the [official documentation](https://learn.microsoft.com/en-us/windows/wsl/install).

#### Install Docker in WSL

Now, you can install Docker inside the WSL:

1. Open a WSL terminal (through the Windows CMD or the WSL terminal)
2. Download the installation script and execute it:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```
   Ignore any warning concerning Docker and WSL.
3. Add your default user to the docker group, so all subsequent docker commands can be executed without root privileges:
   ```bash
   sudo usermod -aG docker $USER
   ```
4. Make sure the Docker Compose plugin is installed, in Debian-based distribution you can type:
   ```bash
   sudo apt-get update
   sudo apt-get install docker-compose-plugin
   ```
5. Finally, make sure that your Linux distro uses the legacy iptables for Docker network isolation:
   ```bash
   sudo update-alternatives --config iptables
   ```

#### Configure Docker

Now that Docker is installed, it is time to configure it.

1. First, make sure to remove the directory `.docker` in your home folder in the WSL: `rm -rf ~/.docker`
2. Then, create it back again, and add a default configuration file:
   ```bash
   mkdir ~/.docker
   echo "{}" > ~/.docker/config.json
   ```
3. Now, you can configure the Docker daemon. Make sure the Docker directory exists (`sudo mkdir -p /etc/docker`) and then edit the file `/etc/docker/daemon.json` to enter the following configuration:
   ```json
   {
     "builder": {
       "gc": {
         "defaultKeepStorage": "20GB",
         "enabled": true
       }
     },
     "features": {
       "buildkit": true
     },
     "experimental": false,
     "hosts": [
       "unix:///var/run/docker.sock"
     ]
   }
   ```
   You can personalize it if you want, but make sure that the hosts property exists (because `systemctl` won't configure it for you) and is configured accordingly to your Docker client, read the [official documentation](https://docs.docker.com/config/daemon/) for more details.
4. Now that Docker is installed, you need to start the Docker Engine. You do that manually, or make sure it launches at Windows startup to avoid doing it manually.
   To start it up manually, enter the following command:
   ```bash
   sudo nohup /usr/bin/dockerd < /dev/null &
   ```

Finally, make sure that Docker is properly configured and running by typing the following command:
```bash
docker version
```

### 🐳 Start `dockerd` daemon at Windows startup

> To install Docker on the WSL without Docker Desktop: https://nickjanetakis.com/blog/install-docker-in-wsl-2-without-docker-desktop

In WSL, configure sudo by executing `sudo visudo` and adding the following line:

```bash
# Allow anyone to start the docker daemon
%sudo ALL=NOPASSWD: /root/start-docker.sh
```

Then, add the file `/root/start-docker.sh` with the following content:

```bash
#!/bin/bash
nohup /usr/bin/dockerd < /dev/null &> /var/log/dockerd.log &
```

> Note that the **stdout** and **stderr** redirection is optional but recommended, otherwise `nohup` will create the `nohup.out` file in `/root/`.

Don't forget to set the execution permission with `sudo chmod 0755 /root/start-docker.sh`.

Make sure to create the log file with the correct permissions:

```bash
sudo mkdir -p /var/log
sudo touch /var/log/dockerd.log
sudo chown root:docker /var/log/dockerd.log
sudo chmod 0664 /var/log/dockerd.log
```

Because `dockerd` will be launched from a custom script and not systemd, we need to configure the Docker daemon by editing the file `/etc/docker/daemon.json` with the following content:

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "features": {
    "buildkit": true
  },
  "experimental": false,
  "hosts": [
    "unix:///var/run/docker.sock"
  ]
}
```

In Windows, open the applications menu with `Super` and search for WSL. Right-click on the icon to select "_Open file location_".
In the explorer, right-click on the `wsl.exe` file and select "_Copy_".
Close the explorer.

Then, use the shortcut `Super`+`R` and type `shell:startup` in the dialog box.
It will open the folder containing all softwares and script to execute at startup.
Right-click and select "_Past shortcut_".
Open the properties of the shortcut, and add the following argument in the target, after the location of the executable file: `sudo /root/start-docker.sh`

The target should look something like:

```bash
"C:\Program Files\WindowsApps\wsl.exe" sudo /root/start-docker.sh
```
