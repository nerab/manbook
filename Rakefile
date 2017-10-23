# encoding: utf-8

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
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "manbook"
  gem.homepage = "http://github.com/nerab/manbook"
  gem.license = "MIT"
  gem.summary = %Q{Produces an eBook from man pages}
  gem.description = %Q{The manbook command can be used to produce an eBook from one or more man pages.}
  gem.email = "nerab@gmx.net"
  gem.authors = ["Nicholas E. Rabenau"]
  gem.executables << 'manbook'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

namespace :test do
  require 'rake/testtask'

  Rake::TestTask.new(:unit) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/unit/test_*.rb'
  end

  Rake::TestTask.new(:integration) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/integration/test_*.rb'
  end
end

task :default => :'test:unit'

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "manbook #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
