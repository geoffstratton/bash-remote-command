#!/bin/bash

SERVER_LIST='servers.txt'
SSH_OPTIONS='-o ConnectTimeout=2'

usage() {
  echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
  echo 'Executes COMMAND as a single command on every server.' >&2
  echo "  -f FILE   Use FILE for the list of servers. Default ${SERVER_LIST}." >&2
  echo '  -f        Dry run mode. Display the COMMAND that would have executed and exit.' >&2
  echo '  -s        Execute the COMMAND using sudo on the remote server.' >&2
  echo '  -v        Verbose mode. Displays the server name before executing COMMAND.' >&2
  exit 1
}

if [[ "${UID}" -eq 0 ]]
then
  echo "Do not execute this script as root!  Use the -s option instead." >&2
  usage
fi

while getopts f:nsv OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    n) DRY_RUN='true' ;;
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage ;;
  esac
done

shift "$(( OPTIND -1 ))"

if [[ "${@#}" -lt 1 ]]
then
  usage
fi

COMMAND="${@}"

if [[ ! -e "${SERVER_LIST}" ]]
then
  echo "Cannot open server list ${SERVER_LIST}." >&2
  exit 1
fi

EXIT_STATUS='0'

for SERVER in $(cat ${SERVER_LIST})
do
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${SERVER}"
  fi

  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"

  if [[ "${DRY_RUN}" = 'true' ]]
  then
    echo "DRY RUN: ${SSH_COMMAND}"
  else
    ${SSH_COMMAND}
    SSH_EXIT_STATUS="${?}"

    if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
    then
      EXIT_STATUS="$PSSH_EXIT_STATSUS}"
      echo "Execution on ${SERVER} failed." >&2
    fi
  fi
done

exit ${EXIT_STATUS}

