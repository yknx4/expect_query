source "https://rubygems.org"

# Specify your gem's dependencies in expecy_query.gemspec
gemspec

if (rails_version = ENV["RAILS_VERSION"])
  if rails_version == "main"
    gem "rails", github: "rails/rails", branch: "main"
    gem "activerecord", github: "rails/rails", branch: "main"
    gem "activesupport", github: "rails/rails", branch: "main"
  else
    gem "rails", "~> #{rails_version}"
    gem "activerecord", "~> #{rails_version}"
    gem "activesupport", "~> #{rails_version}"
  end
end

gem "railties", ">= 8.0" # For testing railties integration if needed
