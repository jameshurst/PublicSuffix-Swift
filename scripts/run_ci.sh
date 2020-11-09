#!/bin/bash

set -exo pipefail

if [ -n "$(git ls-files --others --modified --exclude-standard)" ]; then
  printf "\e[1;31mError: Unclean git environment.\e[0m\n"
  exit -1
fi

scripts/bootstrap.sh

scripts/format.sh
if [ -n "$(git ls-files --others --modified --exclude-standard)" ]; then
  printf "\e[1;31mError: Found changes after running 'scripts/format.sh'.\e[0m\n"
  exit -1
fi

tools/mint run swiftlint --strict

xcodebuild -scheme PublicSuffix clean build test \
  | tools/mint run xcbeautify
