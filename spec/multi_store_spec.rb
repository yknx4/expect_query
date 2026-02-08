# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Multiple Cache Stores" do
  include ExpectQuery::RSpecMatchers

  let(:cache1) { ActiveSupport::Cache::MemoryStore.new }
  let(:cache2) { ActiveSupport::Cache::MemoryStore.new }

  it "counts operations on partial store" do
    expect {
      cache1.write("foo", 1)
      cache2.write("bar", 1)
    }.to perform_cache_operations(total: 1, store: cache1)
  end

  it "counts operations on specific store only" do
    # Verify that it counts operations on the specified store (cache2)
    # and implicitly ignores operations on other stores (cache1)
    # by asserting total is 1 (cache2's write) and not 2 (cache1 + cache2)
    expect {
      cache1.write("foo", 1)
      cache2.write("bar", 1)
    }.to perform_cache_operations(total: 1, store: cache2)
  end

  it "counts operations on multiple stores" do
    expect {
      cache1.write("foo", 1)
      cache2.write("bar", 1)
    }.to perform_cache_operations(total: 2, stores: [cache1, cache2])
  end
end
