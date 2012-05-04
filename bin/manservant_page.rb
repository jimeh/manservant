#!/usr/bin/ruby

# Command line invokation for manservant (https://github.com/jimeh/manservant)
# @ Anand Gupta 2012

# Manservant is a pretty way to view man pages in the browser, rendering them
# in comfortable HTML. 

# This script generates a Manservant page on demand, saving it 
# to /tmp and spawning a browser to view the page

require 'lib/manservant/man_page'
require 'launchy'

# Helpers borrowed from the server
def parse_page_name(dirty_name)
  name = sanitize_name(dirty_name)
  redirect to("/#{name}") if name != dirty_name
  if name =~ /^(.+)\.(\d+?)$/
    [$1, $2]
  else
    [name, nil]
  end
end

def sanitize_name(name)
  name.downcase.gsub(/[^a-z0-9\-_\.]/i, '')
end

def find_page(name, section = nil)
  ManPage.new(name, section,
    :man2html_path => man2html_path,
    :man2html_args => { :cgiurl => '\'/${title}.${section}\'' })
end

def man2html_path
  File.expand_path('./libexec/man2html', __FILE__)
end

# Get the target page
if ARGV.length > 0
  @desired_prog = ARGV[1]
  @name, @section = parse_page_name(params[:page])

  # Build a standalone manservant page
  @page = find_page(@name, @section)
  begin
    # Render it to HTML
    @html = @page.to_html # render and populate sections

    # Fit that HTML into the template

    # Make sure assets are in place

    # Write it out to a /tmp/[file] 

    # Launchy open the file

    # Cleanup rendered pages -- we'll need to let the browser work first

  rescue Manservant::ManPage::NotFound => e
    print 'No manual entry for ', @name
    exit 1
  end
else
  # No target page, should just exit
  print 'What manual page do you want?'
  exit 1
end