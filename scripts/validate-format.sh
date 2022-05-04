#!/bin/bash

set -u

# verify that swiftformat is on the PATH
command -v swiftformat >/dev/null 2>&1 || { echo >&2 "'swiftformat' could not be found. Please ensure it is installed and on the PATH."; exit 1; }

printf "=> Checking format... "
# format the code and exit with error if it was not formatted correctly
FIRST_OUT="$(git status --porcelain)"
swiftformat . > /dev/null || { echo >&2 "'swiftformat' invocation failed"; exit 1; }
SECOND_OUT="$(git status --porcelain)"
if [[ "$FIRST_OUT" != "$SECOND_OUT" ]]; then
  printf "\033[0;31mformatting issues!\033[0m\n"
  git --no-pager diff
  exit 1
else
  printf "\033[0;32mokay.\033[0m\n"
fi
