#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

dir="$SCRIPT_DIR/dir"
malicious_dir="$SCRIPT_DIR/malicious_dir"
whitelist="$SCRIPT_DIR/whitelist.txt"

mkdir -p "$malicious_dir"
touch "$whitelist" || exit 1



for file in "$dir"/*; do
    [ -f "$file" ] || continue

    filename="$(basename "$file")"


    if grep -Fxq -- "$filename" "$whitelist"; then
        continue
    fi

    malicious=false
    extension="${filename##*.}"

    case "$extension" in
        exe|bat|vbs|scr|ps1)
            malicious=true
            ;;
    esac

    if [ "$malicious" = false ] &&
       grep -Eiq 'virus|trojan|malware|worm|ransomware' "$file"; then
        malicious=true
    fi

    if [ "$malicious" = true ]; then
        if cp -- "$file" "$malicious_dir/" &&
           rm -- "$file"; then
            echo "$filename is malicious and it is DELETED"
        else
            echo "Error processing $filename"
        fi
    fi
done
