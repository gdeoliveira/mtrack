require "simplecov" unless ENV["COVERAGE"].nil?
require "byebug"
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "mtrack"
