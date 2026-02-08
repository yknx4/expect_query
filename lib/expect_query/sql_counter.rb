# frozen_string_literal: true

module ExpectQuery
  class SqlCounter
    attr_reader :count, :log

    def initialize(matching: nil)
      @matching = matching
      @count = 0
      @log = []
    end

    def call(_name, _start, _finish, _message_id, payload)
      return if payload[:cached]

      sql = payload[:sql]
      
      # Ignore schema queries, transactions, etc if needed. 
      # For now, we only care about user queries, but let's keep it simple and filter later if requested.
      # Common ignores: SCHEMA, TRANSACTION, EXPLAIN
      return if %w[SCHEMA TRANSACTION EXPLAIN].include?(payload[:name])

      if @matching
        return unless @matching.match?(sql)
      end

      @count += 1
      @log << sql
    end
  end
end
