                                      # Mini_Antivirus Project 
## Purpose : 
Monitor changes in directory "./dir" and check for malicious files that either have a flagged extension or a flagged keyword embedded inside it 

### flagged extensions :  .exe, .bat, .vbs, .scr, .ps1
### flagged keywords : virus, trojan, malware, worm, ransomware

## Behavior : 
## antiviusd.sh file :
initially it checks if the "directory-info.last" file exist which has a snapshot of the last changes to the directory 

### if the file doesn't exist : then it calls the scan_directory() function then it creates the log file 

then it goes through the normal routine :
- wait for a timer of the user choice
- scan the directory for any changes
- compare the changes with the last log
- replace the old log with the new one

  ### scan_directory() method : responsible for the scanning of the file and quarantining the malicious ones

  ## restore.sh file :
  responsible for iterating through the quarantined files and choosing between restoring the file to the normal directory (false flag) or permanently deleting the file

 ## Makefile file :
 used to facilitate the running of the commands and the files 
