#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "usage: ${0} <shell_script>" >&2
  exit 1
fi
shfmt -i 2 -ci "${1}" 
