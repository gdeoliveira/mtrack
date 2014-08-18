desc "Run tests and generate coverage report"
task :coverage do
  if RUBY_VERSION >= "1.9"
    ENV["COVERAGE"] = "true"
  else
    warn "Ruby version 1.9+ is needed in order to generate coverage report."
  end
  Rake::Task[:spec].invoke
end
