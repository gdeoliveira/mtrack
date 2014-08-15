desc "Open a pry console with the #{Bundler::GemHelper.gemspec.name} gem loaded"
task :console do
  require "pry"
  require "byebug"
  require Bundler::GemHelper.gemspec.name

  Pry.start
end
