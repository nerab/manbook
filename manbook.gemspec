# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "manbook"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nicholas E. Rabenau"]
  s.date = "2013-07-22"
  s.description = "The manbook command can be used to produce an eBook from one or more man pages."
  s.email = "nerab@gmx.net"
  s.executables = ["manbook", "mktoc", "manbook"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "TODO"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "TODO",
    "VERSION",
    "bin/manbook",
    "bin/mktoc",
    "lib/manbook.rb",
    "lib/manbook/errors.rb",
    "lib/manbook/formatter.rb",
    "lib/manbook/html_formatter.rb",
    "lib/manbook/log_formatter.rb",
    "lib/manbook/parser.rb",
    "manbook.gemspec",
    "templates/_page.html.erb",
    "templates/about.html.erb",
    "templates/application.html.erb",
    "templates/index.html.erb",
    "templates/library_books.jpg",
    "templates/manbook.ncx.erb",
    "templates/manbook.opf.erb",
    "test/fixtures/alt-cover.jpg",
    "test/fixtures/bash.html",
    "test/fixtures/cat.html",
    "test/fixtures/git.html",
    "test/fixtures/gunzip.html",
    "test/fixtures/less.html",
    "test/fixtures/ls.html",
    "test/fixtures/man.html",
    "test/helper.rb",
    "test/unit/test_manbook.rb",
    "test/unit/test_mktoc.rb"
  ]
  s.homepage = "http://github.com/nerab/manbook"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Produces an eBook from man pages"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 4.0"])
      s.add_runtime_dependency(%q<open4>, ["~> 1.3"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_development_dependency(%q<rake>, ["= 10.1"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8"])
    else
      s.add_dependency(%q<activesupport>, ["~> 4.0"])
      s.add_dependency(%q<open4>, ["~> 1.3"])
      s.add_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_dependency(%q<rake>, ["= 10.1"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 4.0"])
    s.add_dependency(%q<open4>, ["~> 1.3"])
    s.add_dependency(%q<nokogiri>, ["~> 1.5"])
    s.add_dependency(%q<rake>, ["= 10.1"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8"])
  end
end

