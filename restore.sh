#!/bin/bash 


dir="$1"

malicious_dir="$2"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
whitelist="$SCRIPT_DIR/whitelist.txt"



touch "$whitelist" || exit 1

while true ; do 

files=("$malicious_dir"/*)

if [ ! -e "${files[0]}" ] ; then
	echo "no malicious files to review"
	exit 0
fi

echo "quarantined files : "

for i in  "${!files[@]}";
	do
		echo "$((i +1)): $(basename "${files[$i]}")"
	done

echo
read -p "Choose a file number: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] ||
   [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
    echo "Invalid choice."
    continue
fi
 

selected_file="${files[$((choice - 1))]}"
filename="$(basename "$selected_file")"

echo "Selected: $filename"
echo "--------------------------------------------"
echo "1. Restore file"
echo "2. Permanently delete file"
echo "3. Go back"

read -p "Choose an option: " action

case "$action" in
    1)
	if [ -e "$dir/$filename" ] ; then
	    echo "Error : s file with that name already exist in $dir "
	    continue
	fi
	if grep -Fxq -- "$filename" "$whitelist"; then 
	    safe_file_exists=true
	else
	    safe_file_exists=false
	fi
 
        if  mv -- "$selected_file" "$dir/"; then
	    if [ "$safe_file_exists" = false ]; then
		printf '%s\n' "$filename" >> "$whitelist"
	    fi
            echo "Restored $filename to $dir"
	else 
	    echo "failed to restore $filename"
	fi
        ;;
    2)
        if rm -- "$selected_file"; then
          echo "$filename permanently deleted."
	else 
	  echo "failed to delete $filename" 
	fi
        ;;
    3)
        echo "Going back."
        ;;
    *)
        echo "Invalid option."
        ;;
esac

done 
