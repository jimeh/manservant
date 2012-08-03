$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'bundler'
Bundler.setup

require 'manservant'
run Manservant::Server
