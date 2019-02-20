#!/bin/bash

# Author: Jules Maurice Mulisa
# Student ID: S1719024
# Version: 0.1


STUDENTNAME="Jules Maurice Mulisa"
STUDENTID="S1719024"


displayWelcome(){
    echo -e "\r\n**********************************************"
    echo -e "\r\tWELCOME TO SAFE DELETE SCRIPT!"
    echo -e "\r\tWRITTEN BY: $STUDENTNAME"
    echo -e "\r\tSTUDENTID: $STUDENTID"
    echo -e "\r\tSUBMITTED ON: Feb 22, 2019!"
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

# whi le :
# do
#     echo "Hi There"
#     sleep 1
# done

usage(){
	echo "Usage of: $0 script, Available options are: [-l] [-r <option> ][-d] [-t] [-m] [-k]"
}

while getopts lr:dtmk args #options
do
  case $args in
     l) echo "l option";;
     r) echo "r option; data: $OPTARG";;
     d) echo "d option";; 
     t) echo "t option";; 
     w) echo "m option";; 
     k) echo "k option";;     
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
    echo -e "*** YOU ARE IN MENU DRIVEN MODE. CHOOSE ACTION BELOW ***"
    echo -e "********************************************************\r\n"
    if (( $OPTIND == 1 ))
        then select menu_list in $MENU_ITEMS
      do case $menu_list in
         "list") ls -a;;
         "recover") echo "r";;
         "delete") echo "d";;
         "total") echo "t";;
         "watch") echo "I'm watching the srcipt $0";;
         "kill") displayWelcome;;
         "exit") exit 0;;
         *) usage;;
         esac
      done
 fi
else 
	echo "Choose correct usage argument as shown below" 
	usage
fi



