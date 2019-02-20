# SafeDelete_BashScripting
The script simulates the trashcan (recycle-bin) functionalities in the Linux system

## Usage

**Use:** bash safeDel.sh or ./safeDel.sh
### Arguments that can be used

[-l] [-r <option> ][-d] [-t] [-m] [-k]

-l output a list on screen of the contents of the trashCan directory; output should be
properly formatted as “file name” (without path), “size” (in bytes) and “type” for
each file ("safeDel.sh -l")

-r recover i.e. get a specified file from the trashCan directory and place it in the
current directory
("safeDel.sh -r file")

-d delete interactively the contents of the trashCan directory
("safeDel.sh -d").

-t display total usage in bytes of the trashCan directory for the user of the trashcan
("safeDel.sh –t")

-m start monitor script process (see requirements below i.e. "safeDel.sh –w")

-k kill current user’s monitor script processes (i.e. "safeDel.sh –k")

