# frozen_string_literal: true

module ExpectQuery
  class CacheCounter
    attr_reader :counts, :log

    VALID_EVENTS = %w[
      cache_read.active_support
      cache_write.active_support
      cache_fetch_multi.active_support
      cache_read_multi.active_support
      cache_write_multi.active_support
      cache_delete.active_support
      cache_delete_multi.active_support
      cache_exist?.active_support
      cache_increment.active_support
      cache_decrement.active_support
    ].freeze

    def initialize(matching: nil, store_ids: nil)
      @matching = matching
      @store_ids = store_ids
      @counts = Hash.new(0)
      @log = []
    end

    def call(name, _start, _finish, _message_id, payload)
      if @store_ids
        # If we are filtering by store, we must have a matching ID
        return unless @store_ids.include?(payload[:expect_query_store_id])
      end

      # name is like "cache_read.active_support"
      # We want to extract "read", "write", etc.
      operation = name.split(".").first.sub(/^cache_/, "")
      
      key = payload[:key]
      
      if @matching
        # Key can be a string or an array of strings (for multi operations)
        if key.is_a?(Array)
          return unless key.any? { |k| @matching.match?(k.to_s) }
        else
          return unless @matching.match?(key.to_s)
        end
      end

      @counts[operation.to_sym] += 1
      @counts[:total] += 1
      @log << { operation: operation, key: key }
    end
  end
end
