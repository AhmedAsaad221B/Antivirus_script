#!/bin/bash

dir="$1"

malicious_dir="$2"

timer="$3"

extension_list=(exe bat vbs scr ps1)
keywords_list=(virus trojan malware worm ransomware)


scan_directory() {
	malicious=false
	for file in "$dir"/*;
	do
        extension="${file##*.}"
	case "$extension" in 
	   exe | bat | vbs | scr | ps1)
	     echo "file : $file has a melicious extension "
	     malicious=true
	;;
	esac
        
	if grep -Eqi "virus|trojan|malware|worm|ransomware" "$file" ;then 
		malicious=true
	fi
	
	if [ "$malicious" = true ] ; then 
		echo "file : $file is melicious and it is removed "
		malicious=false 
		cp ./"$file" ./"$malicious_dir"
		rm ./"$file"
	fi

	
        done
}


if [ ! -f "directory-info.last" ] ; then
	scan_directory
	ls -l "$dir" > "directory-info.last"
fi

while true 
	do 
		sleep "$timer"
		ls -l "$dir" > "directory-info.new"
		if diff "directory-info.last" "directory-info.new" > /dev/null ;
		 then
			echo "no change" 
		else 
			scan_directory
			ls -l "$dir" > "directory-info.last"
		fi	
	done 





