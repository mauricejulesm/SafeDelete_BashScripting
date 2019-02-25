#!/usr/bin/env bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1


STUDENTNAME="Jules Maurice Mulisa"
STUDENTID="S1719024"

TRASHCAN="/home/$USER/.trashCan"
MONITOR_SCRIPT="./monitor.sh"

# Tells the user what the correct options/arguments should be 
# in case anything goes wrong
usage(){
    echo -e "\r\nUSAGE of this script: [scriptname] [-l], [-r <filename> ],[-d] [-t], [-m], [-k]"
}

# signal is sent whenever the program is interupted
trap 'displayTotalFileNumber' SIGINT
trap 'sayBye' EXIT
displayWelcome(){
    echo -e "\r\n**********************************************"
    echo -e "\r\tWELCOME TO SAFE DELETE SCRIPT!"
    echo -e "\r\tWRITTEN BY: $STUDENTNAME"
    echo -e "\r\tSTUDENT ID: $STUDENTID"
    echo -e "\r\tSUBMITTED : Feb 22, 2019"
    echo -e "**********************************************\r\n"
}
displayWelcome

# dynamically creates the trashcan directory
createTrashCanDir(){
    if [[ ! -d "$TRASHCAN" ]]; then
        # the trashan is dynamically created if it is not present
        mkdir "$TRASHCAN"
        chmod -R 755 $TRASHCAN  # makes sure the directory created has proper permissions

    fi
}
# calling the function that creates the trashcan directory
createTrashCanDir


# **************** Script Functionalities ******************

# checks the number of file in the trashcan ready to be deleted.
TRASHCAN_SIZE=$(ls -lA $TRASHCAN | grep -v ^l | wc -l)
# i used - 1 to get the exact size because the program adds 1 by default.
TRASHCAN_SIZE=$(expr $TRASHCAN_SIZE - 1)
displayTotalFileNumber(){
    echo -e "\r\n\n\t****   Hello $STUDENTNAME, the TrashCan has now $TRASHCAN_SIZE files    ****"
    echo -e "\r\n\t****   The script $0 will terminate now.    ****"
    exit 1
}

displayTrashSizeWarning(){
    local TRASHCAN_SIZE_IN_KLOBTS=""
    TRASHCAN_SIZE_IN_KLOBTS=$(du -sk $TRASHCAN | cut -f1)
    if [[ "$TRASHCAN_SIZE_IN_KLOBTS" -gt 2 ]]; then
    
        echo -e "\r\tWarning! Total size of TrashCan exceeded 2 Kbyte"
        echo -e "\r\n\tCurrent TrashCan Size is: $TRASHCAN_SIZE_IN_KLOBTS Kbytes"
    fi
}
sayBye(){
	# Say bye to the user on exit
	echo -e "\r\n\n**** GOODBYE, $STUDENTNAME, Thank you for using this application. ****"
}
# Lists formatted contents of the trashCan directory on screen
listTrashContent(){
 local COUNTER=1
    # checks first if the argument given is a directory

    if [[ -z $(ls -A "$TRASHCAN") ]]; then
        echo "***Empty trashCan, delete files before listing trashcan contents and try again."
    else
         echo -e "\r\n*** Files in .trashCan directory ***\r\n"
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
    
    # lets the user know whey he/she tries to delete content when the trash is empty
    if [[ -z $(ls -A "$TRASHCAN") ]]; then
        echo "***Empty trashCan, There is nothing to delete!"
    else
        # Shows the number of files in the trash before starting to delete
        echo -e "Beware, $TRASHCAN_SIZE file/files in the trashCan directory ready to delete."

        #when the user wants to delete all files in trashcan
        echo -n "Enter (I/i)to delete files interactively, (E/e)to empty?: "
        read choice

        if [ "$choice" == "I" ] || [ "$choice" == "i" ]; then
           for file in "$TRASHCAN"/*; do

            # for each file, the user can delete or skipp it
            echo -n "Do you want to delete: $(basename $file)(Y/N)?  Enter (Q) or press Enter to start over?"
            read answer
            case $answer in
                Y | y )
                    # -r command make sure the user can even delete subfolders of trashcan
                    rm -r $file
                    echo "File $(basename $file) deleted"
                    ;;
                N | n )
                    echo "File $(basename $file) skipped"
                    ;;
                Q | q*)
                # this helps the user quit the interactive mode
                # in case there is a long list of files to delete interactively 
                echo "Interactive deletion started over"
                    eval deleteTrashContent
                    ;;
            esac
        done 
        elif [ "$choice" == "E" ] || [ "$choice" == "e" ]; then
        rm -rf "$TRASHCAN"/*    # this recursivelly deletes the contents of the trashcan
            echo "TrashCan Emptied successfully!"
        else
            echo "***Wrong choice, Please try again."
        fi
    fi 

} # end of delet function

# Displays total usage in bytes of the trashCan for the user of the trashcan 
displayUsage(){
    # using -sb helpst the get the size in bytes not kilobytes
    echo -e "Total usage of TrashCan directory: 
            $(du -sb $TRASHCAN | cut -f1) Bytes\r\n"
}

# Starts monitor script process in xterm terminal
# Please install xterm if not installed to be able to view modifications
startMonitor(){
    xterm -e $MONITOR_SCRIPT &
    echo "Monitor Script is running..."
}

# Kills the current user’s monitor script processes 
# for better performance please install xterm to view modifications
#  run this command
# sudo apt-get install xterm
killMonitor(){
    echo "***Terminated Monitor Script***"
    kill -9 $!
}

# moveFilesToTrash(){
#     for FILE in $@ ; do
#     done
# }

while getopts :lr:dtwk args #options
do
    case $args in
        l) listTrashContent;;
        r) recoverFile $OPTARG;;
        d) deleteTrashContent;; 
        t) displayUsage;; 
        w) startMonitor;; 
        k) killMonitor;;     
        :) echo "Invalid option, -$OPTARG Please provide a filename after -$OPTARG";;
        \?) usage;;
    esac
done

((pos = OPTIND - 1))
shift $pos

# make the prompt line to the user
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
elif [[ -f $1 ]]; then
        mv "$@" "$TRASHCAN"
        displayTrashSizeWarning
else
    echo "Please provide proper argument as shown below, or correct filename!"
    # show the user the correct usage of the script 
    usage
fi

#End of Script
