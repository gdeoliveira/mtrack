# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mtrack/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 1.9"
  spec.name = "mtrack"
  spec.version = MTrack::VERSION
  spec.authors = ["Gabriel de Oliveira"]
  spec.email = ["deoliveira.gab@gmail.com"]
  spec.summary = "Group and track methods on classes and modules."
  spec.description = <<-EOS
MTrack extends the functionality of modules and classes and enables them to define public methods within groups. These
methods can then be queried back even through a hierarchy of inclusion and/or inheritance.
  EOS
  spec.homepage = "https://github.com/gdeoliveira/mtrack"
  spec.license = "MIT"
  spec.files = `git ls-files -z`.split("\x0")
  spec.test_files = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ["lib"]
  spec.rdoc_options << "--main=MTrack"
end
