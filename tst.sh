#!/bin/sh
#set -euo pipefail
printf "Eingabe: " >/dev/tty
IFS= read -r var </dev/tty
