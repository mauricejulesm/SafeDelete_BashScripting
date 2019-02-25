#!/usr/bin/env bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1

echo "Stated monitoring ..."
TEMP_DIR="/home/$USER/.tempTrashCan"		
TRASHCAN="/home/$USER/.trashCan"

makeTempFiles(){
	rm -rf $TEMP_DIR	
	mkdir $TEMP_DIR		
	chmod -R 755 $TEMP_DIR
	for file in "$TRASHCAN"/*; do
		cp -a $file $TEMP_DIR
	done
}


monitorTrash() {
	while [[ true ]];
	do
	
		makeTempFiles
		
		echo -e "***\r\nStatus of $TRASHCAN directory:"
		for file in "$TRASHCAN"/*; do 
		
			local baseFileName=$(basename $file)	
			local chsumTemp=$(md5sum "$TEMP_DIR/$baseFileName" | awk '{print $1}')
			local chsumTrash=$(md5sum $TRASHCAN/$baseFileName | awk '{print $1}')
			if [[ $chsumTemp != $chsumTrash ]] ; then           
				echo "File: $baseFileName. Status: MODIFIED"
			elif [[ -z $chsumTemp ]]; then
				echo "File: $baseFileName. Status: DELETED"
			else
				echo "File: $baseFileName Status: UNCHANGED"
			fi
		done
		echo "Going to sleep for 15 seconds..."
		sleep 15
		makeTempFiles
	done
	exit 0
}
monitorTrash 

