#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

day="$(date +%d)"

if [ "$day" -ge 15 ] && [ "$day" -le 21 ]; then
    "$SCRIPT_DIR/antivirus-cron.sh"
fi
