# frozen_string_literal: true

require_relative "test_helper"
require "active_support/cache"

class MultiStoreTest < Minitest::Test
  def setup
    @cache1 = ActiveSupport::Cache::MemoryStore.new
    @cache2 = ActiveSupport::Cache::MemoryStore.new
  end

  def test_counts_on_specific_store
    assert_cache_operations(write: 1, store: @cache1) do
      @cache1.write("foo", 1)
      @cache2.write("bar", 1)
    end
  end

  def test_counts_total_on_specific_store
    # Expect 1 total on cache1 (the write), ignoring cache2
    assert_cache_operations(total: 1, store: @cache1) do
      @cache1.write("foo", 1)
      @cache2.write("bar", 1)
    end
  end

  def test_counts_on_multiple_stores
    assert_cache_operations(total: 2, stores: [@cache1, @cache2]) do
      @cache1.write("foo", 1)
      @cache2.write("bar", 1)
    end
  end
  
  def test_default_behavior_uses_rails_cache
    # Should fail to see operations on other caches
    assert_cache_operations(total: 0) do
      @cache1.write("foo", 1)
    end

    # Should see operations on Rails.cache
    assert_cache_operations(total: 1) do
      Rails.cache.write("bar", 1)
    end
  end
end
