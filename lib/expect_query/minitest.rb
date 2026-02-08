# frozen_string_literal: true

module ExpectQuery
  module MinitestAssertions
    def assert_sql_queries(count = nil, matching: nil, at_most: nil, &block)
      counter = ExpectQuery::SqlCounter.new(matching: matching)
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
        block.call
      end
      
      actual = counter.count
      
      debug_info = ""
      if counter.log.any?
        debug_info = "\nQueries run:\n" + counter.log.map.with_index(1) { |sql, i| "#{i}. #{sql}" }.join("\n")
      end

      if at_most
        assert actual <= at_most, "Expected at most #{at_most} SQL queries, but made #{actual}#{debug_info}"
      elsif count
        assert_equal count, actual, "Expected #{count} SQL queries, but made #{actual}#{debug_info}"
      else
        assert actual > 0, "Expected some SQL queries, but made none#{debug_info}"
      end
    end

    def assert_cache_operations(count = nil, matching: nil, store: nil, stores: nil, **specific_counts, &block)
      
      target_stores = Array(stores || store)
      if target_stores.empty? && defined?(::Rails) && ::Rails.respond_to?(:cache)
        target_stores = [::Rails.cache]
      end

      store_ids = []
      target_stores.each do |s|
        unless s.singleton_class < ExpectQuery::StorePatch
          s.singleton_class.prepend(ExpectQuery::StorePatch)
        end
        store_ids << s.object_id
      end

      pass_ids = store_ids.empty? ? nil : store_ids

      counter = ExpectQuery::CacheCounter.new(matching: matching, store_ids: pass_ids)
      
      subscriber = ActiveSupport::Notifications.subscribe(/cache_.*\.active_support/, counter)
      begin
        block.call
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
      
      actual_counts = counter.counts
      
      debug_info = ""
      if counter.log.any?
        debug_info = "\nCache operations performed:\n" + counter.log.map.with_index(1) { |entry, i| "#{i}. #{entry[:operation]}: #{entry[:key]}" }.join("\n")
      end
      
      if count
        assert_equal count, actual_counts[:total].to_i, "Expected #{count} total cache operations, but got #{actual_counts[:total].to_i}#{debug_info}"
      end
      
      specific_counts.each do |op, expected|
        actual = actual_counts[op].to_i
        assert_equal expected, actual, "Expected #{expected} #{op} cache operations, but got #{actual}#{debug_info}"
      end
    end

    def assert_io_operations(sql: nil, cache: nil, &block)
      if sql
        sql_args = sql.dup
        count = sql_args.delete(:count)
        matching = sql_args.delete(:matching)
        at_most = sql_args.delete(:at_most)
        
        # If unknown keys remain in sql_args, we could warn, but for now we verify strictness if possible?
        # assert_sql_queries doesn't take **options, so we can't pass them.
        
        inner_block = if cache
          proc { assert_io_operations(cache: cache, &block) }
        else
          block
        end
        
        assert_sql_queries(count, matching: matching, at_most: at_most, &inner_block)
      elsif cache
        cache_args = cache.dup
        count = cache_args.delete(:count)
        matching = cache_args.delete(:matching)
        store = cache_args.delete(:store)
        stores = cache_args.delete(:stores)
        
        assert_cache_operations(count, matching: matching, store: store, stores: stores, **cache_args, &block)
      else
        block.call
      end
    end
  end
end

if defined?(Minitest::Test)
  Minitest::Test.include ExpectQuery::MinitestAssertions
end
