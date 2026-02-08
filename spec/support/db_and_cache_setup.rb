# frozen_string_literal: true

require "active_record"
require "active_support/cache"

# Setup ActiveRecord
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
  end
end

class User < ActiveRecord::Base
end

# Fake Rails environment for Cache
module Rails
  class << self
    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new
    end
  end
end
