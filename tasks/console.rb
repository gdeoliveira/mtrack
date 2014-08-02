desc "Open a pry console with the gem loaded"
task :console do
  require "pry"
  require "byebug"
  Dir[File.join(File.dirname(__FILE__), "..", "*.gemspec")].each do |file|
    require Gem::Specification.load(file).name
  end

  Pry.start
end
