#!/bin/bash

set -e

setupSSH() {
  local SSH_PATH="$HOME/.ssh"

  mkdir -p "$SSH_PATH"
  touch "$SSH_PATH/known_hosts"

  echo "$INPUT_KEY" > "$SSH_PATH/deploy_key"

  chmod 700 "$SSH_PATH"
  chmod 600 "$SSH_PATH/known_hosts"
  chmod 600 "$SSH_PATH/deploy_key"

  eval $(ssh-agent)
  ssh-add "$SSH_PATH/deploy_key"

  ssh-keyscan -t rsa $INPUT_HOST >> "$SSH_PATH/known_hosts"
}

executeSSH() {
  local LINES=$1
  local COMMAND=""

  # holds all commands separated by semi-colon
  local COMMANDS=""

  # this while read each commands in line and
  # evaluate each line agains all environment variables
  while IFS= read -r LINE; do
    LINE=$(eval 'echo "$LINE"')
    LINE=$(eval echo "$LINE")
    COMMAND=$(echo $LINE)

    if [ -z "$COMMANDS" ]; then
      COMMANDS="$COMMAND"
    else
      COMMANDS="$COMMANDS;$COMMAND"
    fi
  done <<< $LINES

  echo "$COMMANDS"
  ssh -o StrictHostKeyChecking=no -p ${INPUT_PORT:-22} $INPUT_USER@$INPUT_HOST "$COMMANDS"
}

executeSCP() {
  local LINES=$1
  local COMMAND=

  # this while read each commands in line and
  # evaluate each line agains all environment variables
  while IFS= read -r LINE; do
    LINE=$(eval 'echo "$LINE"')
    LINE=$(eval echo "$LINE")
    COMMAND=$(echo $LINE)

    # scp will fail if COMMAND is empty, this condition protects scp
    if [[ $COMMAND = *[!\ ]* ]]; then
      echo "scp -r -o StrictHostKeyChecking=no $COMMAND"
      scp -r -o StrictHostKeyChecking=no $COMMAND
    fi
  done <<< $LINES
}

echo "Running local before: $INPUT_LOCAL_BEFORE"
eval "$INPUT_LOCAL_BEFORE"
setupSSH
echo "+++++++++++++++++++RUNNING BEFORE SSH+++++++++++++++++++"
echo "+++++++++++++++++++RUNNING SCP+++++++++++++++++++"
executeSSH "$INPUT_SSH_BEFORE"
echo "+++++++++++++++++++RUNNING BEFORE SSH+++++++++++++++++++"
echo "+++++++++++++++++++RUNNING SCP+++++++++++++++++++"
executeSCP "$INPUT_SCP"
echo "+++++++++++++++++++RUNNING AFTER SSH+++++++++++++++++++"
executeSSH "$INPUT_SSH_AFTER"
echo "+++++++++++++++++++RUNNING AFTER SSH+++++++++++++++++++"

echo "Running local after: $INPUT_LOCAL_AFTER"
eval $INPUT_LOCAL_AFTER