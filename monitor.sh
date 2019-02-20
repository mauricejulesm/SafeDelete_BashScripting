#!/bin/bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1
TEMP_DIR=".temp"
TRASHCAN=".trashCan"

makeTempFiles(){
	rm -rf $TEMP_DIR
	mkdir $TEMP_DIR
	for file in "$TRASHCAN"/*; do
		cp -a $file $TEMP_DIR
	done
}

monitorTrash() {
	makeTempFiles

	chsum1=""
	chsum2=""

	while [[ true ]];
	do
		echo -e "Here are the changes found in $TRASHCAN directory:"
		for file in "$TRASHCAN"/*; do    	
			md5sum "$TEMP_DIR/$(basename $file)" > "$chsum1"
			md5sum "$TRASHCAN/$file" > "$chsum2"
			# what if the file was deleted
			if [[ $chsum1 != $chsum2 ]] ; then           
				echo "File $file was modified"
				$chsum1=$chsum2
			else
				echo "File $file unchanged"
			fi
		done
		echo "Going to sleep for 15 seconds..."
		sleep 15
	done

}
monitorTrash




# WATCH_STATUS=0

# # echo "I am watching this process ID: $1 and my own pid is $$"

# if [[ -z $1 ]]; then
# 	echo "No PID found please provide a PID to watch"
# 	exit 1
# fi

# echo "Watching PID = $1"
# while [[ $WATCH_STATUS -eq 0 ]]; do
# 	# this sends the the output of ps to a null device
# 	ps $1 > /dev/null
# 	# This $? will look for the last command run,
# 	# then it will stay as 0 if successful and something else if not successful
# 	WATCH_STATUS=$?
# done

# echo "Process $1 has terminated"
# exit 0

# return the user to the safeDel script
# sh ./safeDel.sh

# while :
# do
#     echo "Hi There going to sleep again..."
#     sleep 1
# done



