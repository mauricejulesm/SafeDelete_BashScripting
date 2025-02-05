#!/usr/bin/env bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1


STUDENTNAME="Jules Maurice Mulisa"
STUDENTID="S1719024"

TRASHCAN="/home/$USER/.trashCan"
MONITOR_SCRIPT="./monitor.sh"


usage(){
    echo -e "\r\nUSAGE of this script: [scriptname] [-l], [-r <filename> ],[-d] [-t], [-m], [-k]"
}

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


createTrashCanDir(){
    if [[ ! -d "$TRASHCAN" ]]; then

        mkdir "$TRASHCAN"
        chmod -R 755 $TRASHCAN  

    fi
}

createTrashCanDir


# **************** Script Functionalities ******************

TRASHCAN_SIZE=$(ls -lA $TRASHCAN | grep -v ^l | wc -l)
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

	echo -e "\r\n\n**** GOODBYE, $STUDENTNAME, Thank you for using this application. ****"
}

listTrashContent(){
 local COUNTER=1

    if [[ -z $(ls -A "$TRASHCAN") ]]; then
        echo "***Empty trashCan, delete files before listing trashcan contents and try again."
    else
         echo -e "\r\n*** Files in .trashCan directory ***\r\n"
        for FILE in "$TRASHCAN"/*; do
            echo -e "File $COUNTER:"
            echo -e "\r\tNAME: $(basename $FILE)"
            echo -e "\r\tSIZE: $(stat -c%s $FILE) bytes"
            echo -e "\r\tTYPE: $(file -b --mime-type $FILE)"
            (( COUNTER ++ ))
        done
    fi
}


recoverFile(){

    if [[ ! -e "$TRASHCAN/$1" ]]; then
        echo "***The file you provided does not exit. Try again, Please!"

    elif [[ -e "$1" ]]; then
        echo -n -e "\r\n***Same file found in the destination directory choose: 
                (A/a) to append content, 
                (R/r) to save file with new name, or 
                (O/o) to overwrite contents,
        Enter your Answer here: "
        
        read userAnswer
        case "$userAnswer" in
            A | a)
                cat $TRASHCAN/$1 >> $1
                rm $TRASHCAN/$1
                echo "File contents appended successfully!"
            ;;
            R | r)
                echo -n "Enter new fileName:"
                read newFileName
                mv $TRASHCAN/$1 $newFileName
            ;;
            O | *)
                mv $TRASHCAN/$1 $1
                echo "File overwitten successfully!"
            ;;  
        esac 
    else
        mv $TRASHCAN/$1 $1
        echo "File $(basename $1) has been recovered successfully!"
    fi
}

deleteTrashContent(){

    if [[ -z $(ls -A "$TRASHCAN") ]]; then
        echo "***Empty trashCan, There is nothing to delete!"
    else
        echo -e "Beware, $TRASHCAN_SIZE file/files in the trashCan directory ready to delete."

        echo -n "Enter (I/i)to delete files interactively, (E/e)to empty?: "
        read choice

        if [ "$choice" == "I" ] || [ "$choice" == "i" ]; then
           for file in "$TRASHCAN"/*; do

            echo -n "Do you want to delete: $(basename $file)(Y/N)?  Enter (Q) or press Enter to start over?"
            read answer
            case $answer in
                Y | y )
                    rm -r $file
                    echo "File $(basename $file) deleted"
                    ;;
                N | n )
                    echo "File $(basename $file) skipped"
                    ;;
                Q | q*)
                echo "Interactive deletion started over"
                    eval deleteTrashContent
                    ;;
            esac
        done 
        elif [ "$choice" == "E" ] || [ "$choice" == "e" ]; then
        rm -rf "$TRASHCAN"/*    
            echo "TrashCan Emptied successfully!"
        else
            echo "***Wrong choice, Please try again."
        fi
    fi 

} 

displayUsage(){
    echo -e "Total usage of TrashCan directory: 
            $(du -sb $TRASHCAN | cut -f1) Bytes\r\n"
}
startMonitor(){
    xterm -e $MONITOR_SCRIPT &
    echo "Monitor Script is running..."
}

killMonitor(){
    echo "***Terminated Monitor Script***"
    kill -9 $!
}

while getopts :lr:dtwk args
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

PS3='Choose a number from options above: '

MENU_ITEMS="list recover delete total watch kill exit"

if (( $# == 0 ))
then 
    if (( $OPTIND == 1 ))
    then
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
    usage
fi
