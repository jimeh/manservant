# Command line invokation for manservant (https://github.com/jimeh/manservant)
# @ Anand Gupta 2012

# Manservant is a pretty way to view man pages in the browser, rendering them
# in comfortable HTML. 

# This script generates a Manservant page on demand, saving it 
# to /tmp and spawning a browser to view the page

require './man_page'
require 'launchy'
require 'erb'

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
  Manservant::ManPage.new(name, section,
    :man2html_path => man2html_path,
    :man2html_args => { :cgiurl => '\'/${title}.${section}\'' })
end

def man2html_path
  File.expand_path('../../../libexec/man2html', __FILE__)
end

def build_template
    # We have to replicate sinatra/rails page composing here
    # This is kinda hacky, but the idea is to not pull in any deps

    # Make sure assets are in place
    # TODO 
    
    # Pull open the layout
    layout = File.read(
              File.expand_path('../server/views/layout.erb',
                               __FILE__))
    # Pull open the page body template
    page_body = File.read(
                  File.expand_path('../server/views/page.erb',
                                    __FILE__))
    # Stuff the body in the layout 
    # the layout has a big "<%= yield %>" that we're targeting
    composed = layout.sub('<%= yield %>', page_body)

    # Feed the composed templates to ERB
    return composed
end


def build_page(name, section = nil) 
    # Build a standalone manservant page
  puts 'Building...'
  begin
    @page = find_page(name, section)

    # Build a template
    template_str = build_template()

    # Invoke ERB
    page_template = ERB.new(template_str, 0, "%<>")
    rendered_page = page_template.result(binding)

    filename = '/tmp/man_'+name+'.html'

    # Write it out to a /tmp/[file] 
    File.open(filename, 'w') {|file| file.write(rendered_page) }



    # Launchy open the file
    Launchy.open('file://'+filename)

    # Cleanup rendered pages -- 
    #   we'll need to let the browser work first
    # TODO 
    
  rescue Manservant::ManPage::NotFound => e
    puts 'No manual entry for ', name
    exit 1
  end
end

# Main

# Get the target page
if ARGV.length > 0
  name, section = parse_page_name(ARGV[0])
  build_page(name, section)
else
  # No target page, should just exit
  puts 'What manual page do you want?'
  exit 1
end