# frozen_string_literal: true

require_relative "test_helper"

class ExpectQueryTest < Minitest::Test
  def setup
    Rails.cache.clear
  end

  def test_assert_sql_queries
    assert_sql_queries(1) do
      User.create(name: "Foo")
    end
  end

  def test_assert_sql_queries_at_most
    assert_sql_queries(at_most: 3) do
      User.create(name: "Foo")
      User.count
    end
  end

  def test_assert_sql_queries_matching
    assert_sql_queries(1, matching: /INSERT/) do
      User.create(name: "Foo")
    end
  end
  
  def test_assert_sql_queries_failure
    assert_raises(Minitest::Assertion) do
      assert_sql_queries(1, matching: /UPDATE/) do
        User.create(name: "Foo")
      end
    end
  end

  def test_assert_cache_operations
    assert_cache_operations(total: 2) do
      Rails.cache.read("foo")
      Rails.cache.write("bar", 1)
    end
  end

  def test_assert_cache_operations_specific
    assert_cache_operations(read: 1, write: 1) do
      Rails.cache.read("foo")
      Rails.cache.write("bar", 1)
    end
  end
end
