#!/bin/bash 


dir="$1"

malicious_dir="$2"

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

echo "Selected: $(basename "$selected_file")"
echo "--------------------------------------------"
echo "1. Restore file"
echo "2. Permanently delete file"
echo "3. Go back"

read -p "Choose an option: " action

case "$action" in
    1)
        mv -- "$selected_file" "$dir/"
        echo "File restored."
        ;;
    2)
        rm -- "$selected_file"
        echo "File permanently deleted."
        ;;
    3)
        echo "Going back."
        ;;
    *)
        echo "Invalid option."
        ;;
esac

done 
