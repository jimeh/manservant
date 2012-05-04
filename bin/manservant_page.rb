#!/usr/bin/ruby

# Command line invokation for manservant (https://github.com/jimeh/manservant)
# @ Anand Gupta 2012

# Manservant is a pretty way to view man pages in the browser, rendering them
# in comfortable HTML. 

# This script generates a Manservant page on demand, saving it 
# to /tmp and spawning a browser to view the page

require 'lib/manservant/man_page'
require 'process'

# Check if there's a cached/open version of the page already

# Build a standalone manservant page
    # Create a ManPage object
    # Render it to HTML
    # Fit that HTML into the template
    # Make sure assets are in place
# Write it out to a /tmp/[file] 