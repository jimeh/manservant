# -*- encoding: utf-8 -*-
require File.expand_path('../lib/manservant/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jim Myhrberg']
  gem.email         = ['contact@jimeh.me']
  gem.description   = 'Turn the man into a servant. Serve man pages over http.'
  gem.summary       = 'Turn the man into a servant.'
  gem.homepage      = 'https://github.com/jimeh/manservant'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'manservant'
  gem.require_paths = ["lib"]
  gem.version       = Manservant::VERSION

  gem.add_runtime_dependency 'sinatra', '~> 1.3.0'

  gem.add_development_dependency 'rspec'
end
