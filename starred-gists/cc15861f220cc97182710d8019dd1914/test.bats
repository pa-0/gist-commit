#!/usr/bin/env bats

export TOOL_NAME='gist'
export GIST_USER='phamhsieh'
export GIST_API_TOKEN='dd43dc9949a5b4a1d6c7''b779f13af357282016e4'

@test "Testing ${TOOL_NAME} tool" {
  echo "${TOOL_NAME}"
}

@test "The help command should print usage" {
  run ./gist help

  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" = "${TOOL_NAME}" ]]
}

@test "Use config command to add configuarion for user" {
  run ./gist config user ${GIST_USER}
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "user='${GIST_USER}'" ]
}

@test "Use config command to add configuarion for token" {
  run ./gist config token ${GIST_API_TOKEN}
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "token=${GIST_API_TOKEN}" ]
}

@test "The new command should create a new public gist with gist command" {
  hint=false run ./gist new --file gist --desc 'Manage gist like a pro' gist
  [ "$status" -eq 0 ]
  [[ "${lines[-1]}" =~ ([0-9]+ +https://gist.github.com/[0-9a-z]+) ]]
}

@test "The fetch command should fetch user gists" {
  hint=false run ./gist fetch
  [ "$status" -eq 0 ]
  [[ "${lines[-1]}" =~ ([0-9]+ +https://gist.github.com/[0-9a-z]+) ]]
}

@test "The fetch command should fetch starred gists" {
  hint=false run ./gist fetch star
  [ "$status" -eq 0 ]
  echo ${lines[-1]}
  [[ "${lines[-1]}" =~ (Not a single valid gist|^ *s[0-9]+ +https://gist.github.com/[0-9a-z]+) ]]
}

@test "No arguments prints the list of gists" {
  hint=false run ./gist 
  [ "$status" -eq 0 ]
  [[ "${lines[-1]}" =~ ([0-9]+ +https://gist.github.com/[0-9a-z]+) ]]
}

@test "Specify an index to return the path of cloned repo" {
  run ./gist 1 --no-action
  [ "$status" -eq 0 ]
  [[ "${lines[-1]}" =~ (${HOME}/gist/[0-9a-z]+) ]]
}

@test "The edit command should modify the description of a gist" {
  ./gist edit 1 "Modified description"
  run ./gist detail 1
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ (Modified description$) ]]
}

@test "The delete command should delete specified gists" {
  run ./gist delete 1 --force
  [ "$status" -eq 0 ]
}

@test "The user command should get the list of public gists from a user" {
  hint=false run ./gist user defunkt
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ (https://gist.github.com/[0-9a-z]+ defunkt) ]]
}
