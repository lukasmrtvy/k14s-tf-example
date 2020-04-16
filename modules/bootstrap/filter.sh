#!/bin/bash

set -e

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function parse_input() {
  eval "$(jq -r '@sh "export RAW=\(.raw) NAMESPACE=\(.namespace)"')"
  if ! kfilt <<< "$RAW" >/dev/null 2>&1 ; then
   error_exit "kfilt failed."
  fi
}

function check_deps() {
  command -v jq >/dev/null 2>&1 || error_exit "Helper: I require jq but it's not installed. Aborting."
  command -v kfilt >/dev/null 2>&1 || error_exit "Helper: I require kfilt but it's not installed. Aborting."
}

function main() {
    ns=$(kfilt -i kind=namespace <<< "$RAW")
    other=$(kfilt -x kind=namespace <<< "$RAW")

    jq -n --arg ns "$ns" --arg other "$other" '{"ns":$ns,"other":$other}'
    exit 0
}

check_deps
parse_input
main
