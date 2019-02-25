#!/usr/bin/env bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1

echo "Stated monitoring ..."
TEMP_DIR="/home/$USER/.tempTrashCan"		# the path to the .temp dir used to check the md5sum of tile is the trashcan
TRASHCAN="/home/$USER/.trashCan"
# the function used to update the .temp directory for future comparisons
makeTempFiles(){
	rm -rf $TEMP_DIR	# removes the temp dir to make sure it gets updated data
	mkdir $TEMP_DIR		# makes the temp dir
	chmod -R 755 $TEMP_DIR	# makes sure the directory created has proper permissions
	# the for loop copies the contents of trashcan dir to the temp forder for future comparisons.
	# the /* was used as a whild card to help get the content of the trashcan as a list
	for file in "$TRASHCAN"/*; do
		cp -a $file $TEMP_DIR
	done
}

# function to monitor the changes made to the trashcan dir on the home dir
monitorTrash() {

	# the while to run till the function to kill the monitor script is called
	while [[ true ]];
	do
	
		# makes sure the temp directory is updated before using it.
		makeTempFiles
		
		echo -e "***\r\nStatus of $TRASHCAN directory:"
		for file in "$TRASHCAN"/*; do 
			
			# retrieves the name of file without the dir   	
			local baseFileName=$(basename $file)	
			# gives the md5sum of the current file in temp dir
			local chsumTemp=$(md5sum "$TEMP_DIR/$baseFileName" | awk '{print $1}')
			# gives the md5sum of the current file in trash dir
			local chsumTrash=$(md5sum $TRASHCAN/$baseFileName | awk '{print $1}')
			# check if the checksums are different
			if [[ $chsumTemp != $chsumTrash ]] ; then           
				echo "File: $baseFileName. Status: MODIFIED"
				# if $chsumTemp of the current file is not found in tem dir that means it was deleted in trash
			elif [[ -z $chsumTemp ]]; then
				echo "File: $baseFileName. Status: DELETED"
			# if the checksums are equal then the file is unchanged
			else
				echo "File: $baseFileName Status: UNCHANGED"
			fi
		done
		echo "Going to sleep for 15 seconds..."

		# makes the process go to sleep for 15 seconds
		sleep 15
		# update the temp folder
		makeTempFiles
	done
	exit 0
}

# calls the function monitorTrash to begin
monitorTrash 

