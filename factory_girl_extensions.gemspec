# -*- encoding: utf-8 -*-
require File.expand_path("../lib/factory_girl_extensions/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "factory_girl_extensions"
  gem.author      = "remi"
  gem.email       = "remi@remitaylor.com"
  gem.homepage    = "http://github.com/remi/factory_girl_extensions"
  gem.summary     = "Alternative FactoryGirl API"

  gem.description = <<-desc.gsub(/^\s+/, '')
    Alternative FactoryGirl API allowing you to build/generate factories 
    using your class constants, eg. User.gen instead of Factory(:user).
  desc

  files = `git ls-files`.split("\n")
  gem.files         = files
  gem.executables   = files.grep(%r{^bin/.*}).map {|f| File.basename(f) }
  gem.test_files    = files.grep(%r{^spec/.*})
  gem.require_paths = ["lib"]
  gem.version       = FactoryGirlExtensions::VERSION

  gem.add_dependency "factory_girl", ">= 2.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
end
