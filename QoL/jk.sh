#!/bin/bash

readonly script_name=$(basename $(pwd))

function hmsg {
#function that prints the help message
        cat << EOF
Usage: $script_name.sh [-hlp] [list of files]
   -h: Display help.
   -l: List junked files.
   -p: Purge all files.
   [list of files] with no other arguments to junk those files.
EOF
}

if [[ $# = 0 ]]; then
#if there is nothing passed in as an argument then the display message needs to be printed
    hmsg
    exit
fi

num_flags=0
flag=""

function check_flags {
#checks that there is only one valid flag
    if [[ $num_flags -gt 1 ]]; then
        echo Error: Too many options enabled.
        hmsg
        exit
    fi
}

while getopts ":hlp" opt; do
    case "${opt}" in
        h)
            ((++num_flags))
            check_flags
            #hmsg
            flag="-${opt}"
            ;;
        l) 
            ((++num_flags))
            check_flags
            flag="-${opt}"
            ;;
        p)
            ((++num_flags))
            check_flags
            flag="-${opt}"
            ;;
        ?)
            #if an unknown flag is passed, then we print an error and the help message
            echo Error: Unknown option \'-$OPTARG\'.
            hmsg
            exit
            ;;
    esac
done

if [[ $num_flags -eq 1 && $# -gt 1 ]]; then
    #if there is one valid flag and at least one file passed an argument (not allowed)
    echo Error: Too many options enabled.
    hmsg
    exit
fi

readonly junk=$HOME/.junk
if [[ ! -d $junk ]]; then
    mkdir -p $HOME/.junk    #creates hidden junk directory to store junked files
fi

if [[ $flag == "-h" ]]; then   
    hmsg
    exit
elif [[ $flag == "-l" ]]; then
    ls -lAF $junk
elif [[ $flag == "-p" ]]; then
    rm -rf $HOME/.junk      #removes all files in directory
elif [[ $num_flags -eq 0 ]]; then
    for elem in "$@"; do
        if [[ -d $elem ]]; then
            mv $(pwd)/$elem/ $junk
        elif [[ -e $elem ]]; then
            mv $(pwd)/$elem $junk
        elif [[ ! -e $elem ]]; then
            echo Warning: \'$elem\' not found.
        else
            echo how did we get here?
        fi
    done
fi

exit
