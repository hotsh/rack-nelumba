# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-lotus"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hackers of the Severed Hand']
  s.email       = ['hotsh@xomb.org']
  s.homepage    = "http://github.com/hotsh/rack-lotus"
  s.summary     = %q{Rack extension that provides a generalized federated system backend for social networks with ActivityStreams/OStatus/pump.io.}
  s.description = %q{This gem allows easier implementation and utilization of rack-based web services that are distributed and federated.}

  s.add_dependency "sinatra", "> 1.0" # Routes (requires version specifier due to bundler thinking '1.0' is newest otherwise)
  s.add_dependency "bson_ext"         # Database
  s.add_dependency "mongo_mapper"     # Database
  s.add_dependency "bcrypt-ruby"      # Basic Authentication
  s.add_dependency "rmagick"          # Used for avatar resizing

  s.add_dependency "tilt"             # Preferred template interface
  s.add_dependency "haml"             # Preferred HTML template language

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
