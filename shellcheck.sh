#!/usr/bin/env bash

set -e

targets=()
while IFS=  read -r -d $'\0'; do
    targets+=("$REPLY")
done < <(
  find \
    lib \
    services \
    tasks \
    shellcheck.sh \
    lan-bot \
    lb-logger \
    -type f \
    -print0
  )

for file in "${targets[@]}"; do
  [ -f "${file}" ] && LC_ALL=C.UTF-8 shellcheck "${file}"
done;