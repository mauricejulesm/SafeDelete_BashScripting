#!/bin/bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1

# TODO: try using redirectors (<)

STUDENTNAME="Jules Maurice Mulisa"
STUDENTID="S1719024"


displayWelcome(){
    echo -e "\r\n**********************************************"
    echo -e "\r\tWELCOME TO SAFE DELETE SCRIPT!"
    echo -e "\r\tWRITTEN BY: $STUDENTNAME"
    echo -e "\r\tSTUDENT ID: $STUDENTID"
    echo -e "\r\tSUBMITTED : Feb 22, 2019"
    echo -e "**********************************************\r\n"
}

displayWelcome
# usa can ask user first if they want to use cmd driven or menu driven
# as a way of interacting with the program


# signal is sent whenever the program exits with status 0
trap 'echo $0 is terminated with status 0' exit 0

# signal is sent whenever the program exits with status 1
trap 'echo $0 is terminated with status 1' exit 1

# signal is sent whenever the program exits anyhow
#trap 'echo $0 is terminated at any exit' exit 


#you can also have a program do something within a trap
# the following lists files in directory when SIGINT or Ctrl+C is pressed.
# trap 'echo "I am gonna list files in current directory"; ls -l' SIGINT

# **************** Functions ******************

# Tells the user what the correct options/arguments should be 
# in case anything goes wrong
usage(){
	echo -e "\r\nUSAGE OF: $0 script: [-l] [-r <option> ][-d] [-t] [-m] [-k]"
}

TRASHCAN=".trashCan"
# Lists formatted contents of the trashCan directory on screen
listTrashContent(){
 local COUNTER=1
 echo -e "\r\n*** Files in .trashCan directory ***\r\n"
    # checks first if the argument given is a directory
    if [[ -d "$TRASHCAN" ]]; then
        # list the files in the given directory
        for FILE in "$TRASHCAN"/*; do
            echo -e "File $COUNTER:"
            echo -e "\r\tNAME: $(basename $FILE)"
            echo -e "\r\tSIZE: $(stat -c%s $FILE) bytes"
            echo -e "\r\tTYPE: $(file -b --mime-type $FILE)"
            (( COUNTER ++ ))
        done
    fi
}

# Gets a specified file from the trashCan directory and place it in the current directory
recoverFile(){
    # check if the file exists in the trashCan directory.
    if [[ ! -e "$TRASHCAN/$1" ]]; then
        echo "The file you provided does not exit. Try again, Please!"
    else
        # if exists move it the current directory
        mv $TRASHCAN/$1 $1
        echo "File $(basename $1) has been recovered successfully!"
    fi
}

# Interactively deletes the contents of the trashCan directory 
deleteTrashContent(){
    echo "Function deleteTrashContent is called."
}

# Displays total usage in bytes of the trashCan directory for the user of the trashcan 
displayUsage(){
    echo -e "Total usage of TrashCan directory: $(du -h $TRASHCAN) bytes"
}

# Starts monitor script process
startMonitor(){
    echo "Function startMonitor is called."
}

# Kills the current user’s monitor script processes 
killMonitor(){
    echo "Function  killMonitor is called."
}

while getopts lr:dtwk args #options
do
    case $args in
        l) listTrashContent $OPTARG;;
        r) recoverFile $OPTARG;;
        d) deleteTrashContent;; 
        t) displayUsage;; 
        w) startMonitor;; 
        k) killMonitor;;     
        :) echo "data missing, option -$OPTARG";;
        \?) usage;;
    esac
done

((pos = OPTIND - 1))
shift $pos

PS3='Choose a number from options above: '

MENU_ITEMS="list recover delete total watch kill exit"

if (( $# == 0 ))
then 
    if (( $OPTIND == 1 ))
    then
        # Let the user know that they are in the menu mode
        echo -e "*** YOU ARE IN MENU DRIVEN MODE. CHOOSE ACTION BELOW ***"
        echo -e "********************************************************\r\n" 
        
        select menu_list in $MENU_ITEMS
        do 
            case $menu_list in
                "list") listTrashContent;;
                "recover")
                    echo -n "Enter the name of the file you want to recover:"
                    read  fileName
                    recoverFile $fileName;;
                "delete") deleteTrashContent;;
                "total") displayUsage;;
                "watch") startMonitor;;
                "kill") killMonitor;;
                "exit") exit 0;;
                *) usage;;
            esac
        done
    fi
else 
	echo "Choose the correct argument as shown in the usage below" 
	usage
fi



