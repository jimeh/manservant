#!/bin/sh

# Command line invokation for manservant (https://github.com/jimeh/manservant)
# @ Anand Gupta 2012

# Manservant is a pretty way to view man pages in the browser, rendering them
# in comfortable HTML. 

# This script allows you to bring up the manservant version of any man page 
# from the command line, such that one could type 'man tmux', and go straight
# to the browser

# This will only support OSX and some linux distros, given that it relies on 
# 'open' or 'xdg-open'

MANSERVANT_HOST="http://localhost:9292"

unamestr=`uname`

# OS Detection
if [[ "$unamestr" == 'Darwin' ]]; then
    open "$MANSERVANT_HOST/$1"
elif [[ "$unamestr" == 'Linux' ]]; then
    # Pipe the stdout/err out of the way. 
    xdg-open "$MANSERVANT_HOST/$1" &> /dev/null &
fi
    
