# -*- encoding: utf-8 -*-
require File.expand_path('../lib/brahman/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["onk"]
  gem.email         = ["takafumi.onaka@gmail.com"]
  gem.description   = %q{Subversion Branch Manager}
  gem.summary       = %q{brahman command which can merge a branch more easily.}
  gem.homepage      = "https://github.com/onk/brahman"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "brahman"
  gem.require_paths = ["lib"]
  gem.version       = Brahman::VERSION
end
