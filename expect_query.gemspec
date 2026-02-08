# frozen_string_literal: true

require_relative "lib/expect_query/version"

Gem::Specification.new do |spec|
  spec.name = "expect_query"
  spec.version = ExpectQuery::VERSION
  spec.authors = ["Jade Ornelas"]
  spec.email = ["jade@ornelas.io"]

  spec.summary = "A gem to assert SQL queries and Cache operations count."
  spec.description = "Provides RSpec matchers and Minitest assertions to count SQL queries and Cache operations, supporting Rails 8.0+."
  spec.homepage = "https://github.com/yknx4/expect_query"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yknx4/expect_query"
  spec.metadata["changelog_uri"] = "https://github.com/yknx4/expect_query/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Rails 8.0+ requirement
  spec.add_dependency "activesupport", ">= 8.0"
  spec.add_dependency "activerecord", ">= 8.0"

  # Development dependencies
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"
end
