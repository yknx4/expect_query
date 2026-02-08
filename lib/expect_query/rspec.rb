# frozen_string_literal: true

require "rspec/expectations"

module ExpectQuery
  module RSpecMatchers
    def make_sql_queries(count = nil, matching: nil, at_most: nil)
      MakeSqlQueries.new(count, matching: matching, at_most: at_most)
    end

    def perform_cache_operations(count = nil, matching: nil, store: nil, stores: nil, **counts)
      PerformCacheOperations.new(count, matching: matching, store: store, stores: stores, **counts)
    end

    class MakeSqlQueries
      include RSpec::Matchers::Composable

      def initialize(expected, matching: nil, at_most: nil)
        @expected = expected
        @matching = matching
        @at_most = at_most
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        @counter = ExpectQuery::SqlCounter.new(matching: @matching)
        ActiveSupport::Notifications.subscribed(@counter, "sql.active_record") do
          block.call
        end
        
        @actual = @counter.count
        
        if @at_most
          @actual <= @at_most
        elsif @expected
          @actual == @expected
        else
          @actual > 0 # generic "makes queries"
        end
      end

      def failure_message
        msg = "expected to make "
        msg += "#{@expected} " if @expected
        msg += "at most #{@at_most} " if @at_most
        msg += "SQL queries"
        msg += " matching #{@matching.inspect}" if @matching
        msg += ", but made #{@actual}"
        
        if @counter.log.any?
          msg += "\nQueries run:\n"
          msg += @counter.log.map.with_index(1) { |sql, i| "#{i}. #{sql}" }.join("\n")
        end
        msg
      end
    end

    class PerformCacheOperations
      include RSpec::Matchers::Composable

      def initialize(total = nil, matching: nil, store: nil, stores: nil, **specific_counts)
        @total = total
        @matching = matching
        @specific_counts = specific_counts
        @stores = Array(stores || store)
        
        if @stores.empty? && defined?(::Rails) && ::Rails.respond_to?(:cache)
          @stores = [::Rails.cache]
        end
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        # Patch stores
        store_ids = []
        @stores.each do |store|
          unless store.singleton_class < ExpectQuery::StorePatch
            store.singleton_class.prepend(ExpectQuery::StorePatch)
          end
          store_ids << store.object_id
        end

        # If no stores are defined (e.g. no Rails.cache and no store passed), we can't strict filter by ID.
        # But we probably should pass empty array if we intended to track but found nothing? 
        # Or if store_ids is empty, maybe we track ALL?
        # User said: "By default use Rails.cache". If Rails.cache is missing, maybe we should warn or track nothing?
        # Let's pass nil if we want to track ALL, but if we defaulted to Rails.cache and it's there, we pass it.
        # If user explicitly passed empty list?
        pass_ids = store_ids.empty? ? nil : store_ids

        @counter = ExpectQuery::CacheCounter.new(matching: @matching, store_ids: pass_ids)
        
        subscriber = ActiveSupport::Notifications.subscribe(/cache_.*\.active_support/, @counter)
        begin
          block.call
        ensure
          ActiveSupport::Notifications.unsubscribe(subscriber)
        end
        
        @actual_counts = @counter.counts
        
        result = true
        
        if @total
          result &&= (@actual_counts[:total].to_i == @total)
        end
        
        @specific_counts.each do |op, count|
           # op could be :read, :write
           result &&= (@actual_counts[op].to_i == count)
        end
        
        result
      end

      def failure_message
        msg = "expected to perform cache operations: "
        msg += "total #{@total}, " if @total
        @specific_counts.each { |k, v| msg += "#{k}: #{v}, " }
        msg += "matching #{@matching.inspect}" if @matching
        msg += "\nbut got: "
        msg += "total #{@actual_counts[:total].to_i}, "
        @specific_counts.each { |k, _| msg += "#{k}: #{@actual_counts[k].to_i}, " }
        
        if @counter.log.any?
          msg += "\nCache operations performed:\n"
          msg += @counter.log.map.with_index(1) { |entry, i| "#{i}. #{entry[:operation]}: #{entry[:key]}" }.join("\n")
        end
        msg
      end
    end
  end
end

RSpec.configure do |config|
  config.include ExpectQuery::RSpecMatchers
end
