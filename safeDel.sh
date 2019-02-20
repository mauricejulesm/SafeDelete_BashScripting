#!/bin/bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1

# TODO: try using redirectors (<)

STUDENTNAME="Jules Maurice Mulisa"
STUDENTID="S1719024"

TRASHCAN=".trashCan"
MONITOR_SCRIPT="./monitor.sh"

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
trap 'echo $0 is terminated with int' 1

# signal is sent whenever the program exits with status 1
trap 'echo $0 is terminated by quit'  0

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

# TODO make the move of many files possible
# Gets a specified file from the trashCan directory and place it in the current directory
recoverFile(){
    # check if the specified file really exists in the trashCan directory.
    if [[ ! -e "$TRASHCAN/$1" ]]; then
        echo "***The file you provided does not exit. Try again, Please!"

    # check if there is a file with the same name in the destination directory (current).
    elif [[ -e "$1" ]]; then
        echo -n -e "\r\n***Same file found in the destination directory choose: 
                (A/a) to append content, 
                (R/r) to save file with new name, or 
                (O/o) to overwrite contents,
        Enter your Answer here: "
        
        read userAnswer
        case "$userAnswer" in
            A | a)
                # if there is existing same file but wants to keep both files' contents. 
                cat $TRASHCAN/$1 >> $1
                rm $TRASHCAN/$1
                echo "File contents appended successfully!"
            ;;
            R | r)
                # the user can choose to keep the  with same name in destination,
                # but recover the one in trash with a new name
                echo -n "Enter new fileName:"
                read newFileName
                mv $TRASHCAN/$1 $newFileName
            ;;
            O | *)
                # this does the default mv functionality which is overwriting the content of file
                mv $TRASHCAN/$1 $1
                echo "File overwitten successfully!"
            ;;  
        esac # end the switch case
    else
        # if exists and there is no other same file move it gracefully to the current directory
        mv $TRASHCAN/$1 $1
        echo "File $(basename $1) has been recovered successfully!"
    fi
}

# Interactively deletes the contents of the trashCan directory 
deleteTrashContent(){
    for file in $TRASHCAN; do
        read answer
        echo -n "Do you want to delete: $(basename $file)?(Y/N)"
        case $answer in
            Y | y )
                rm $file
                echo "File $(basename $file) deleted"
                ;;
            N | * )
            echo "File skipped"
                ;;
        esac
    done
}

# Displays total usage in bytes of the trashCan for the user of the trashcan 
displayUsage(){
    echo -n "Total usage of TrashCan directory: 
            $(du -sb $TRASHCAN | cut -f1) Bytes\r\n"
}

# Starts monitor script process
startMonitor(){
    # local SAFE_DEL_PID=$BASHPID
    # echo "The process id of safeDel script is : $SAFE_DEL_PID"
    sh $MONITOR_SCRIPT $TRASHCAN 2
    # echo "Monitor Script is running..."
}

# Kills the current user’s monitor script processes 
killMonitor(){
    kill -SIGKILL $(pidof $MONITOR_SCRIPT)
    echo "Monitor Script is terminated"
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



