require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification
  # (See http://docs.rubygems.org/read/chapter/20 for more options)
  gem.name = "deltoid"
  gem.homepage = "http://github.com/djsun/deltoid"
  gem.license = "MIT"
  gem.summary = %Q{Deltoid finds differences between two or more HTML documents.}
  gem.description = %Q{Deltoid diffs HTML documents using a relatively simple N-way algorithm. It reports deltas as an array of hashes, where each hash contains :content, :xpath, and :index keys.}
  gem.email = "davidcjames@gmail.com"
  gem.authors = ["David James"]

  gem.add_runtime_dependency 'nokogiri', '~> 1.4'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'jeweler', '~> 1.5'
  gem.add_development_dependency 'rspec', '~> 2.1'
  gem.add_development_dependency 'unindentable'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = "-c -fd" # color, documentation format
end
task :default => :spec