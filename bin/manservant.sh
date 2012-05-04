#!/bin/sh

# Command line invokation for manservant (https://github.com/jimeh/manservant)
# @ Anand Gupta 2012

# Manservant is a pretty way to view man pages in the browser, rendering them
# in comfortable HTML. 

# This script allows you to bring up the manservant version of any man page 
# from the command line, such that one could type 'man tmux', and go straight
# to the browser

ruby ./lib/manservant/open_manserver_page "$@"
