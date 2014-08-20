desc "Open a console with the #{Bundler::GemHelper.gemspec.name} gem loaded"
task :console do
  require Bundler::GemHelper.gemspec.name

  if RUBY_VERSION >= "1.9"
    begin
      require "pry"
    rescue LoadError
      require "irb"
    end
  else
    require "irb"
  end

  if defined? Pry
    Pry.start
  else
    ARGV.clear
    IRB.start
  end
end
