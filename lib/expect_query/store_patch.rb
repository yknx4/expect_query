# frozen_string_literal: true

module ExpectQuery
  module StorePatch
    def instrument(name, key, options = nil, &block)
      options ||= {}
      options = options.dup unless options.frozen? # dup if possible to avoid mutation issues, though usually safe
      options = options.merge(expect_query_store_id: object_id)
      super(name, key, options, &block)
    end
  end
end
