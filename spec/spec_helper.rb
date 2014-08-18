unless ENV["COVERAGE"].nil?
  require "codeclimate-test-reporter"
  SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter
    ]
    add_filter "/spec/"
  end
end
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "mtrack"
