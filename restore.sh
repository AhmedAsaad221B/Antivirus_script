#!/bin/bash 


dir="dir"

malicious_dir="malicious_dir"

files=("$malicious_dir"/*)

if [ ! -e "${files[0]}" ] ; then
	echo "NO QUARANTINED FILES"
	exit 0
fi

echo "quarantined files : "

for i in  "${!files[@]}";
	do
		echo "$((i +1)): $(basename "${files[$i]}")"
	done
