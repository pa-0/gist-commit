#!/bin/bash

#===============================================================================
# Bash Cheatsheet
# Author: Claude (AI Language Model)
# Date: 2023-06-13
#===============================================================================

#===============================================================================
# Table of Contents
#===============================================================================
# 1. Basic Commands
# 2. Variables
# 3. Input/Output
# 4. Conditionals
# 5. Loops
# 6. Functions
# 7. Arrays
# 8. Strings
# 9. File Operations
# 10. Process Handling
# 11. Debugging
# 12. Whiptail Commands
# 13. Tips and Tricks

#===============================================================================
# 1. Basic Commands
#===============================================================================

# Print working directory
pwd

# List files and directories
ls
ls -l    # List in long format
ls -a    # List all files (including hidden)
ls -t    # List files sorted by modification time
ls -R    # List files recursively

# Change directory
cd
cd /path/to/directory    # Change to specific directory
cd ~    # Change to home directory
cd -    # Change to previous directory

# Create directory
mkdir directory_name
mkdir -p /path/to/directory    # Create intermediate directories if they don't exist

# Remove empty directory
rmdir directory_name

# Remove files and directories
rm file_name
rm -r directory_name    # Remove directory and its contents recursively
rm -f file_name         # Force removal without confirmation

# Copy files and directories
cp source_file destination_file
cp -r source_directory destination_directory    # Copy directory recursively

# Move or rename files and directories
mv old_name new_name

# Create symbolic link
ln -s /path/to/file link_name

# Print file contents
cat file_name
cat file1 file2    # Concatenate files and print

# Print file contents with pagination
less file_name

# Print first 10 lines of a file
head file_name
head -n 5 file_name    # Print first 5 lines

# Print last 10 lines of a file
tail file_name
tail -n 5 file_name    # Print last 5 lines

# Search for patterns in files
grep pattern file_name
grep -r pattern directory_name    # Search recursively in directory
grep -i pattern file_name         # Case-insensitive search
grep -v pattern file_name         # Invert match (lines not containing pattern)

# Find files and directories
find /path/to/directory -name "pattern"    # Find by name
find /path/to/directory -type f            # Find only files
find /path/to/directory -type d            # Find only directories
find /path/to/directory -size +100M        # Find files larger than 100MB

# Execute command with root privileges
sudo command

#===============================================================================
# 2. Variables
#===============================================================================

# Declare a variable
variable_name="value"

# Access a variable
echo $variable_name

# Read-only variable
readonly variable_name="value"

# Delete a variable
unset variable_name

# Variable scope (local)
local variable_name="value"

# Environment variables
export variable_name="value"

# Command substitution
variable_name=$(command)

# Arithmetic expansion
result=$((expression))

#===============================================================================
# 3. Input/Output
#===============================================================================

# Read user input
read variable_name
read -p "Prompt: " variable_name    # Prompt for input
read -s variable_name               # Read input silently (for passwords)

# Print to stdout
echo "Hello, World!"
printf "Hello, %s!\n" "John"

# Redirect stdout to a file
command > file_name
command >> file_name    # Append to a file

# Redirect stderr to a file
command 2> file_name
command 2>> file_name    # Append to a file

# Redirect both stdout and stderr to a file
command &> file_name
command &>> file_name    # Append to a file

# Redirect stdin from a file
command < file_name

# Here Document
command << EOF
input
input
EOF

# Here String
command <<< "input"

#===============================================================================
# 4. Conditionals
#===============================================================================

# If statement
if [[ condition ]]; then
   # commands
elif [[ condition ]]; then
   # commands
else
   # commands
fi

# Case statement
case "$variable" in
   pattern1)
       # commands
       ;;
   pattern2)
       # commands
       ;;
   *)
       # default commands
       ;;
esac

# Conditional expressions
[[ -z "$variable" ]]    # Check if variable is empty
[[ -n "$variable" ]]    # Check if variable is not empty
[[ "$str1" == "$str2" ]]    # String equality
[[ "$str1" != "$str2" ]]    # String inequality
[[ $num1 -eq $num2 ]]       # Numeric equality
[[ $num1 -ne $num2 ]]       # Numeric inequality
[[ $num1 -lt $num2 ]]       # Less than
[[ $num1 -le $num2 ]]       # Less than or equal to
[[ $num1 -gt $num2 ]]       # Greater than
[[ $num1 -ge $num2 ]]       # Greater than or equal to

#===============================================================================
# 5. Loops
#===============================================================================

# For loop
for variable in item1 item2 item3; do
   # commands
done

# C-style for loop
for ((i=0; i<10; i++)); do
   # commands
done

# While loop
while [[ condition ]]; do
   # commands
done

# Until loop
until [[ condition ]]; do
   # commands
done

# Break and continue
for item in list; do
   if [[ condition ]]; then
       break
   fi
   if [[ condition ]]; then
       continue
   fi
   # commands
done

#===============================================================================
# 6. Functions
#===============================================================================

# Define a function
function function_name() {
   # commands
}

# Call a function
function_name arg1 arg2

# Function arguments
$1    # First argument
$2    # Second argument
$@    # All arguments as separate words
$*    # All arguments as a single word
$#    # Number of arguments

# Return value
return_value=0
return $return_value

#===============================================================================
# 7. Arrays
#===============================================================================

# Declare an array
array_name=(item1 item2 item3)

# Access array elements
echo ${array_name[0]}    # First element
echo ${array_name[*]}    # All elements
echo ${array_name[@]}    # All elements
echo ${#array_name[@]}   # Number of elements

# Modify array elements
array_name[0]="new_item"

# Iterate over array elements
for item in "${array_name[@]}"; do
   # commands
done

#===============================================================================
# 8. Strings
#===============================================================================

# String length
length=${#string}

# Substring
substring=${string:start:length}

# String replacement
new_string=${string//pattern/replacement}

# String splitting
IFS=","
read -ra arr <<< "$string"

# String concatenation
result="$str1$str2"

#===============================================================================
# 9. File Operations
#===============================================================================

# Check if file exists
if [[ -e "$file" ]]; then
   # commands
fi

# Check if directory exists
if [[ -d "$directory" ]]; then
   # commands
fi

# Create file
touch file_name

# Remove file
rm file_name

# Rename file
mv old_name new_name

# Copy file
cp source_file destination_file

# Symlink
ln -s /path/to/file link_name

# File permissions
chmod 644 file_name    # Set read/write for owner, read for others
chmod +x file_name     # Add execute permission for everyone
chmod -R 755 directory_name    # Set permissions recursively

#===============================================================================
# 10. Process Handling
#===============================================================================

# Run command in background
command &

# List running jobs
jobs

# Bring background job to foreground
fg job_id

# Suspend current foreground job
Ctrl+Z

# Resume suspended job in background
bg job_id

# Terminate a process
kill pid
kill -9 pid    # Force terminate

# Check process status
ps
ps aux    # List all processes

# Wait for a process to finish
wait pid

#===============================================================================
# 11. Debugging
#===============================================================================

# Enable debugging mode
set -x

# Disable debugging mode
set +x

# Print trace of function calls
set -o functrace

# Print shell input lines as they are read
set -v

# Print commands and their arguments as they are executed
set -x

# Ignore errors and continue execution
command || true

# Exit immediately if a command exits with a non-zero status
set -e

# Print an error message and exit
echo "Error: Something went wrong" >&2
exit 1

#===============================================================================
# 12. Whiptail Commands
#===============================================================================

# Display a message box
whiptail --title "Message" --msgbox "Hello, World!" 8 40

# Display an input box
result=$(whiptail --title "Input" --inputbox "Enter your name:" 8 40 3>&1 1>&2 2>&3)

# Display a password box
password=$(whiptail --title "Password" --passwordbox "Enter your password:" 8 40 3>&1 1>&2 2>&3)

# Display a yes/no box
if whiptail --title "Confirmation" --yesno "Are you sure?" 8 40; then
   # User selected "Yes"
else
   # User selected "No"
fi

# Display a menu
options=("Option 1" "Option 2" "Option 3")
choice=$(whiptail --title "Menu" --menu "Choose an option:" 15 40 3 "${options[@]}" 3>&1 1>&2 2>&3)

# Display a checklist
options=("Option 1" "Option 2" "Option 3")
selected=$(whiptail --title "Checklist" --checklist "Select options:" 15 40 3 "${options[@]}" 3>&1 1>&2 2>&3)

# Display a radio list
options=("Option 1" "Option 2" "Option 3")
selected=$(whiptail --title "Radio List" --radiolist "Select an option:" 15 40 3 "${options[@]}" 3>&1 1>&2 2>&3)

# Display a gauge
for ((i=0; i<=100; i+=10)); do
   sleep 1
   echo $i
done | whiptail --title "Progress" --gauge "Please wait..." 6 50 0

#===============================================================================
# 13. Tips and Tricks
#===============================================================================

# Brace expansion
echo {1..10}    # Sequence: 1 2 3 4 5 6 7 8 9 10
echo {a..z}     # Sequence: a b c ... x y z
echo {A..Z}     # Sequence: A B C ... X Y Z
echo file{1..3}.txt    # File names: file1.txt file2.txt file3.txt

# Parameter expansion
${variable:-default}    # Use default value if variable is unset or empty
${variable:=default}    # Set variable to default value if unset or empty
${variable:?error}      # Display error if variable is unset or empty
${variable:+value}      # Use alternative value if variable is set and not empty

# Shebang
#!/bin/bash    # Specify bash as the interpreter for the script

# Conditionally execute command based on exit status
command1 && command2    # Execute command2 only if command1 succeeds
command1 || command2    # Execute command2 only if command1 fails

# Redirection
command > file    # Redirect stdout to file (overwrite)
command >> file   # Redirect stdout to file (append)
command 2> file   # Redirect stderr to file (overwrite)
command 2>> file  # Redirect stderr to file (append)
command &> file   # Redirect both stdout and stderr to file (overwrite)
command < file    # Redirect file to stdin

# Here Document
command << EOF
input
input
EOF

# Arithmetic expansion
result=$((expression))    # Perform arithmetic operation and store result in variable

# Process substitution
diff <(command1) <(command2)    # Compare output of command1 and command2

# Subshell
(cd /path/to/directory && command)    # Execute command in a subshell with a different working directory

# Traps
trap 'echo "Interrupted!"' INT    # Execute command when interrupt signal (Ctrl+C) is received
trap 'echo "Terminated!"' TERM    # Execute command when termination signal is received
trap 'echo "Exiting..."; exit' EXIT    # Execute command when script exits

# Bash options
set -e    # Exit immediately if a command exits with a non-zero status
set -u    # Treat unset variables as an error and exit immediately
set -x    # Print commands and their arguments as they are executed
set -o pipefail    # Return value of a pipeline is the status of the last command to exit with a non-zero status

# Aliases
alias ll='ls -alF'    # Create an alias for a commonly used command

# Prompt customization
PS1="\u@\h \w $ "    # Customize the prompt to show username, hostname, and current directory

# History
history    # View command history
!<number>    # Execute a command from history by its number
!!    # Execute the last command
!<string>    # Execute the most recent command starting with <string>
Ctrl+R    # Search command history interactively

# Job control
Ctrl+Z    # Suspend the current foreground process
bg    # Resume the most recently suspended process in the background
fg    # Bring the most recently backgrounded process to the foreground
jobs    # List all background jobs

# Bash completion
Tab    # Trigger auto-completion
Tab Tab    # Display all possible completions

# Multiline commands
command1 \
command2 \
command3

# Heredoc with indentation
<<-EOF
   This is a heredoc
   with indentation
EOF

# Redirecting file descriptor
exec 3>&1    # Save current stdout to file descriptor 3
exec 1>output.txt    # Redirect stdout to a file
echo "This goes to the file"
exec 1>&3    # Restore stdout from file descriptor 3
echo "This goes to the console"

# Temporary files and directories
temp_file=$(mktemp)    # Create a temporary file
temp_dir=$(mktemp -d)    # Create a temporary directory

# Redirecting output to multiple commands
command | tee file1 file2 > file3

# Case conversion
echo "${string^^}"    # Convert to uppercase
echo "${string,,}"    # Convert to lowercase

# Random number generation
random_number=$RANDOM    # Generate a random number between 0 and 32767
random_number=$((RANDOM % 100 + 1))    # Generate a random number between 1 and 100

# Parsing command-line arguments
while [[ "$#" -gt 0 ]]; do
   case $1 in
       -o|--option) option="$2"; shift ;;
       -h|--help) display_help; exit ;;
       *) echo "Unknown argument: $1" >&2; exit 1 ;;
   esac
   shift
done

# Colorized output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'    # No color
echo -e "${RED}Error: ${NC}Something went wrong"
echo -e "${GREEN}Success: ${NC}Operation completed"

# Keyboard input
read -rsn1 -t5 key    # Read a single character without echoing, with a timeout of 5 seconds
case "$key" in
   [Yy]) echo "Yes" ;;
   [Nn]) echo "No" ;;
   *) echo "Invalid input" ;;
esac

# Plotting with Gnuplot
gnuplot <<- EOF
   set title "Plot Title"
   set xlabel "X-axis label"
   set ylabel "Y-axis label"
   plot "data.txt" using 1:2 with lines
EOF

# Curses-based interfaces with dialog
dialog --title "Menu" --menu "Choose an option:" 15 40 3 \
   1 "Option 1" \
   2 "Option 2" \
"Option 3"

# Logging
exec > >(tee -a log.txt)    # Redirect stdout to both console and log file
exec 2> >(tee -a error.log >&2)    # Redirect stderr to both console and error log file

# Sending email
echo "Subject: Alert" | sendmail -s "Alert" user@example.com

# Downloading files
wget -O output.zip https://example.com/file.zip    # Download file and save as output.zip
curl -o output.tar.gz https://example.com/file.tar.gz    # Download file and save as output.tar.gz

# Extracting archives
tar -xvf archive.tar    # Extract tar archive
tar -xzvf archive.tar.gz    # Extract gzipped tar archive
unzip archive.zip    # Extract zip archive

# SSH commands
ssh user@host    # Connect to remote host via SSH
ssh user@host command    # Execute command on remote host via SSH
scp file.txt user@host:/path/to/destination    # Copy file to remote host via SSH
scp user@host:/path/to/file.txt .    # Copy file from remote host via SSH

# Running commands in parallel
command1 &
command2 &
command3 &
wait    # Wait for all background commands to finish

# Checking disk space
df -h    # Display disk space usage in human-readable format
du -sh /path/to/directory    # Display size of a directory in human-readable format

# Checking memory usage
free -h    # Display memory usage in human-readable format
vmstat    # Display virtual memory statistics
top    # Display real-time system information, including memory usage

# Checking CPU usage
top    # Display real-time system information, including CPU usage
mpstat    # Display CPU usage statistics
sar    # Collect, report, and save system activity information

# Network troubleshooting
ping host    # Send ICMP echo request to host
traceroute host    # Trace route to host
nslookup domain    # Query DNS for domain information
netstat -tunlp    # Display listening ports and associated processes

# Performance monitoring
iostat    # Report CPU and I/O statistics
vmstat    # Report virtual memory statistics
sar    # Collect, report, and save system activity information
dstat    # Versatile tool for generating system resource statistics

# Text manipulation
sed 's/pattern/replacement/g' file    # Replace pattern with replacement globally in file
awk '{print $1}' file    # Print first column of file
cut -d ',' -f 1,3 file    # Cut fields 1 and 3 from CSV file
sort file    # Sort lines of file
uniq file    # Remove duplicate lines from file
tr 'a-z' 'A-Z' < file    # Convert lowercase to uppercase in file
grep -v pattern file    # Print lines not matching pattern in file

# Date and time
date    # Display current date and time
date +"%Y-%m-%d"    # Display current date in YYYY-MM-DD format
date -d "1 day ago"    # Display date 1 day ago
date -d "1 week"    # Display date 1 week in the future

# Scheduling tasks
echo "command" | at 10:00    # Schedule command to run at 10:00
echo "command" | at now + 1 hour    # Schedule command to run 1 hour from now
crontab -e    # Edit crontab file to schedule recurring tasks

# Compiling and running C programs
gcc -o program program.c    # Compile C program
./program    # Run compiled C program

# Compiling and running Java programs
javac Program.java    # Compile Java program
java Program    # Run compiled Java program

# Compiling and running Python programs
python program.py    # Run Python program

# Git commands
git init    # Initialize a new Git repository
git clone https://github.com/user/repo.git    # Clone a Git repository
git add .    # Stage all changes for commit
git commit -m "Commit message"    # Commit staged changes with a message
git push origin main    # Push commits to the main branch of the origin remote

# Docker commands
docker build -t image:tag .    # Build a Docker image from a Dockerfile in the current directory
docker run -d --name container image:tag    # Run a Docker container in detached mode
docker ps    # List running Docker containers
docker stop container    # Stop a running Docker container
docker rm container    # Remove a Docker container

# Kubernetes commands
kubectl apply -f deployment.yaml    # Apply a Kubernetes deployment from a YAML file
kubectl get pods    # List Kubernetes pods
kubectl logs pod    # View logs of a Kubernetes pod
kubectl exec -it pod -- bash    # Open an interactive shell in a Kubernetes pod
kubectl scale deployment --replicas=3    # Scale a Kubernetes deployment to 3 replicas

# AWS CLI commands
aws ec2 describe-instances    # Describe EC2 instances
aws s3 ls    # List S3 buckets
aws iam list-users    # List IAM users
aws lambda invoke --function-name my-function output.txt    # Invoke a Lambda function
aws cloudformation create-stack --stack-name my-stack --template-body file://template.yaml    # Create a CloudFormation stack

# GCP CLI commands
gcloud compute instances list    # List Compute Engine instances
gcloud storage ls    # List Cloud Storage buckets
gcloud iam service-accounts list    # List service accounts
gcloud functions deploy my-function --runtime python37 --trigger-http    # Deploy a Cloud Function
gcloud deployments create my-deployment --config deployment.yaml    # Create a deployment using a YAML configuration file

# Azure CLI commands
az vm list    # List virtual machines
az storage account list    # List storage accounts
az ad user list    # List Azure Active Directory users
az functionapp create --name my-function --resource-group my-resource-group --storage-account my-storage-account    # Create a Function App
az deployment group create --resource-group my-resource-group --template-file template.json    # Create a deployment using an ARM template

# Terraform commands
terraform init    # Initialize a Terraform working directory
terraform plan    # Generate and show an execution plan
terraform apply    # Apply the changes required to reach the desired state of the configuration
terraform destroy    # Destroy the Terraform-managed infrastructure

# Ansible commands
ansible all -m ping    # Ping all hosts in the inventory
ansible-playbook playbook.yml    # Run an Ansible playbook
ansible-vault encrypt secrets.yml    # Encrypt a file containing sensitive data using Ansible Vault
ansible-galaxy init role_name    # Initialize a new Ansible role
ansible-doc -l    # List available Ansible modules

# Puppet commands
puppet apply manifest.pp    # Apply a Puppet manifest
puppet module install author-module    # Install a Puppet module from the Puppet Forge
puppet cert list    # List all SSL certificates
puppet resource user    # Manage user resources using Puppet
puppet agent --test    # Run a Puppet agent in test mode

# Chef commands
knife cookbook create cookbook_name    # Create a new Chef cookbook
knife node list    # List all registered Chef nodes
knife data bag create bag_name    # Create a new data bag
knife role create role_name    # Create a new role
knife bootstrap node_name    # Bootstrap a new node and register it with the Chef server