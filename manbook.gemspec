# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: manbook 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "manbook".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nicholas E. Rabenau".freeze]
  s.date = "2022-04-30"
  s.description = "The manbook command can be used to produce an eBook from one or more man pages.".freeze
  s.email = "nerab@gmx.net".freeze
  s.executables = ["manbook".freeze, "mktoc".freeze, "manbook".freeze]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "TODO"
  ]
  s.files = [
    ".document",
    ".github/dependabot.yml",
    ".ruby-version",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "Guardfile",
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
    "lib/manbook/page.rb",
    "lib/manbook/parser.rb",
    "manbook.gemspec",
    "templates/_page.html.erb",
    "templates/about.html.erb",
    "templates/application.html.erb",
    "templates/index.html.erb",
    "templates/library_books.jpg",
    "templates/manbook.ncx.erb",
    "templates/manbook.opf.erb",
    "test/fixtures/about.html",
    "test/fixtures/alt-cover.jpg",
    "test/fixtures/bash.html",
    "test/fixtures/cat.html",
    "test/fixtures/git.html",
    "test/fixtures/gunzip.html",
    "test/fixtures/less.html",
    "test/fixtures/ls.html",
    "test/fixtures/man.html",
    "test/helper.rb",
    "test/integration/test_manbook.rb",
    "test/integration/test_mktoc.rb",
    "test/unit/test_page.rb"
  ]
  s.homepage = "http://github.com/nerab/manbook".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Produces an eBook from man pages".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<open4>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 2.2.10"])
    s.add_development_dependency(%q<jeweler>.freeze, [">= 0"])
    s.add_development_dependency(%q<guard-minitest>.freeze, [">= 0"])
    s.add_development_dependency(%q<guard-bundler>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<open4>.freeze, [">= 0"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 2.2.10"])
    s.add_dependency(%q<jeweler>.freeze, [">= 0"])
    s.add_dependency(%q<guard-minitest>.freeze, [">= 0"])
    s.add_dependency(%q<guard-bundler>.freeze, [">= 0"])
  end
end

