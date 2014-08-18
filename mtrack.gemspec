# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mtrack/version"

Gem::Specification.new do |spec|
  spec.name          = "mtrack"
  spec.version       = MTrack::VERSION
  spec.authors       = ["Gabriel de Oliveira"]
  spec.email         = ["deoliveira.gab@gmail.com"]
  spec.summary       = %q{Group and track methods on classes and modules.}
  spec.description   = <<-EOS.strip.gsub(/\n/, "").gsub(/\s{2,}/, " ")
                         MTrack extends the functionality of modules and
                         classes and enables them to define public methods
                         within groups. These methods can then be queried back
                         even through a hierarchy of inclusion and/or
                         inheritance.
                       EOS
  spec.homepage      = "https://github.com/gdeoliveira/mtrack"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
