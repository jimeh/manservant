$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'manservant'
run Manservant::Server
