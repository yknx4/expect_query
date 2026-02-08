# frozen_string_literal: true

require_relative "expect_query/version"
require_relative "expect_query/store_patch"
require_relative "expect_query/sql_counter"
require_relative "expect_query/cache_counter"
require "active_support"
require "active_support/notifications"

module ExpectQuery
  class Error < StandardError; end
end
