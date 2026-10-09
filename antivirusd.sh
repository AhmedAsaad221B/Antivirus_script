#!/bin/bash

dir="$1"
malicious_dir="$2"
timer="$3"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
whitelist="$SCRIPT_DIR/whitelist.txt"
last_snapshot="$SCRIPT_DIR/directory-info.last"
new_snapshot="$SCRIPT_DIR/directory-info.new"

extension_list=(exe bat vbs scr ps1)
keywords_list=(virus trojan malware worm ransomware)

touch "$whitelist" || exit 1

scan_directory() {

    for file in "$dir"/*; do
        [ -f "$file" ] || continue

        filename="$(basename "$file")"

        if grep -Fxq -- "$filename" "$whitelist"; then
            echo "$filename is whitelisted. Skipping."
            continue
        fi

        malicious=false
        extension="${filename##*.}"

        case "$extension" in
            exe|bat|vbs|scr|ps1)
                malicious=true
                ;;
        esac

        if grep -Eqi 'virus|trojan|malware|worm|ransomware' "$file"; then
            malicious=true
        fi

        if [ "$malicious" = true ]; then
            echo "$filename is malicious and it is DELETED"

            if [ -e "$malicious_dir/$filename" ]; then
                echo "Error: Quarantine already contains $filename. Skipping."
                continue
            fi

            if cp -- "$file" "$malicious_dir/"; then
                if rm -- "$file"; then
                    :
                else
                    echo "Error: Could not remove original $filename."
                fi
            else
                echo "Error: Could not quarantine $filename."
            fi
        fi
    done


}

if [ ! -f "$last_snapshot" ]; then
    scan_directory
    ls -l "$dir" > "$last_snapshot"
fi

while true; do
    sleep "$timer"

    ls -l "$dir" > "$new_snapshot"

    if diff "$last_snapshot" "$new_snapshot" > /dev/null; then
        echo "No change"
    else
        scan_directory
        ls -l "$dir" > "$last_snapshot"
    fi
done
