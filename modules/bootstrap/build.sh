#!/bin/bash

set -e

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function parse_input() {
  eval "$(jq -r '@sh "export DIR=\(.dir)"')"
  if ! cd "$DIR" && kustomize build . >/dev/null 2>&1; then
   error_exit "Kustomize build failed."
  fi
}

function check_deps() {
  command -v jq >/dev/null 2>&1 || error_exit "Helper: I require jq but it's not installed. Aborting."
  command -v kustomize >/dev/null 2>&1 || error_exit "Helper: I require kustomize but it's not installed. Aborting."
}

function main() {
    raw=$(cd "$DIR" && kustomize build .)
    jq -n --arg raw "$raw" '{"raw":$raw}'
    exit 0

}

check_deps
parse_input
main
