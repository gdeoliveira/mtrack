desc "Open a console with the #{Bundler::GemHelper.gemspec.name} gem loaded"
task :console do
  require Bundler::GemHelper.gemspec.name

  if RUBY_VERSION >= "1.9"
    require "pry"
    Pry.start
  else
    require "irb"
    ARGV.clear
    IRB.start
  end
end
