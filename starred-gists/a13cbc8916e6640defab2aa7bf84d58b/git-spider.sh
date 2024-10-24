#! /bin/bash
#==============================================================================#
#           ________________   _____ ____  ________  __________ 
#          / ____/  _/_  __/  / ___// __ \/  _/ __ \/ ____/ __ \
#         / / __ / /  / /     \__ \/ /_/ // // / / / __/ / /_/ /
#        / /_/ // /  / /     ___/ / ____// // /_/ / /___/ _, _/ 
#        \____/___/ /_/     /____/_/   /___/_____/_____/_/ |_|  
#                                                         
#==============================================================================#
#
# INTRODUCTION
# ______________________________________________________________________________
# |                |                                                            |
# |  Script Name   |  git-spider                                                |
# |  Source Code   |  http://bit.ly/git-spider                                  |
# |  Version       |  1.0                                                       |
# |  About         |  Search Github.com with unauthenticated API calls          |
# |  Author        |  h8rt3rmin8r (for resonova.com)                            |
# |  Date          |  20190127                                                  |
# |  Dependencies  |  bash, cat, curl, head, jq, sed, tail                      |
# |________________|____________________________________________________________|
#
# USAGE
#
#    ./git-spider.sh <OPTION> <USERNAME>
#    ./git-spider.sh <OPTION> <USERNAME> <REPO>
#
#    Example: ./git-spider.sh --user "resonova"
#    Example: ./git-spider.sh --repo-forks "resonova" "glitchpad.com"
#
# OPTIONS
# ______________________________________________________________________________
# |                        |                                                    |
# |  -h,--help             |  Print this help text information                  |
# |  -u,--user             |  Get details about a specific Github user account  |
# |  --uf,--user-followers |  Get a list of a user's followers                  |
# |  -r,--repo             |  Get details about a specific Github repository    |
# |  --rf,--repo-forks     |  Get details on forks of a specific repository     |
# |________________________|____________________________________________________|
#
# INSTALLATION
#
#      Save this script locally as "git-spider.sh" and make it executable:
#         sudo chmod +x git-spider.sh
#
#      Run the script in the following manner:
#         ./git-spider.sh --help
#
#      Enable this script to have global execution availability by placing it 
#      into /usr/local/bin (or somewhere else in your user's PATH). By doing
#      this, you can call "git-spider.sh" from anywhere on the system.
#
# LICENSE
#
#      Copyright 2018 ResoNova International Consulting, LLC
#
#      Licensed under the Apache License, Version 2.0 (the "License");
#      you may not use this file except in compliance with the License.
#      You may obtain a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#      Unless required by applicable law or agreed to in writing, software
#      distributed under the License is distributed on an "AS IS" BASIS,
#      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#      See the License for the specific language governing permissions and
#      limitations under the License.
#
#==============================================================================#
# VARIABLE ASSIGNMENTS

HERE=$(pwd)
USER=$(cd; pwd | cut -c 7-)
HOME="/home/${USER}"
SELF_FILE="${0##*/}"
SELF="[${SELF_FILE}]"
API_ROOT="https://api.github.com"
USERNAME="$2"
REPO="$3"

#==============================================================================#
# FUNCTION DECLARATIONS

function gh_getinfo_user() {
    # Get details about a specific Github user account
    curl -s "${API_ROOT}/users/${USERNAME}" | jq '.'
    return
}

function gh_getinfo_user_followers() {
    # Get a list of accounts that follow a specific account
    curl -s "${API_ROOT}/users/${USERNAME}/followers" | jq '.'
    return
}

function gh_getinfo_repo() {
    # Fetch details about a specific Github repository
    curl -s "${API_ROOT}/repos/${USERNAME}/${REPO}" | jq '.'
    return
}

function gh_getinfo_repo_forks() {
    # Fetch details on the forks of a specific repository
    curl -s "${API_ROOT}/repos/${USERNAME}/${REPO}/forks" | jq '.'
    return
}

function gh_helptext() {
    # Script help text function
    cat $0 | head -n 39 | tail -n +3 | sed 's/#/ /g'
    return
}

#==============================================================================#
# INPUT VALIDATION AND OPERATIONS EXECUTION

if [[ "x$1" == "x" ]];
then
    echo "${SELF} ERROR: No inputs detected!"
    echo "${SELF} Try '--help' for more information"
    exit 1
fi
if [[ "$1" == "-h" || "$1" == "-help" || "$1" == "--help" ]];
then
    gh_helptext
    exit 0
fi
if [[ "x$2" == "x" ]];
then
    echo "${SELF} ERROR: Missing a SECOND parameter!"
    echo "${SELF} Try '--help' for more information"
    exit 1
fi

case "$1" in
    -u|-user|--user|-username|--username)
        # Get details about a specific Github user account
        gh_getinfo_user
        exit 0
        ;;
    -uf|--uf|-user-followers|--user-followers)
        # Get a list of accounts that follow a specific account
        gh_getinfo_user_followers
        exit 0
        ;;
    -r|-repo|--repo|-repository|--repository)
        # Get details about a specific Github repository
        if [[ "x$3" == "x" ]];
        then
            echo "${SELF} ERROR: Missing a THIRD parameter!"
            echo "${SELF} When using the '--repo' parameter, you must specify a repository."
            exit 1
        fi
        gh_getinfo_repo
        exit 0
        ;;
    -rf|--rf|-repo-forks|--repo-forks|-repository-forks|--repository-forks)
        # Get details on the forks of a specific repository
        if [[ "x$3" == "x" ]];
        then
            echo "${SELF} ERROR: Missing a THIRD parameter!"
            echo "${SELF} When using the '--repo-forks' parameter, you must specify a repository."
            exit 1
        fi
        gh_getinfo_repo_forks
        exit 0
        ;;
esac

#==============================================================================#
                                                   #                           #
                                                   #  "think outside the box"  #
                                                   #                           #
                                                   #    ($) ¯\_(ツ)_/¯ (฿)     #
                                                   #                           #
                                                   #===========================#