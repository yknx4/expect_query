# ExpectQuery

`expect_query` provides Rails 8.0+ compatible assertions and matchers for counting SQL queries and Cache operations. It supports both RSpec and Minitest, offering powerful tools to prevent N+1 queries and ensure efficient caching.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'expect_query', group: :test
```

## Usage

### RSpec

Add this to your `spec_helper.rb`:

```ruby
require "expect_query/rspec"
```

#### SQL Assertions

Verify the number of SQL queries executed.

```ruby
# Exact count
expect { 
  User.first 
}.to make_sql_queries(1)

# At most (useful for reducing N+1 without being brittle)
expect {
  User.all.each(&:profile)
}.to make_sql_queries(at_most: 3)

# Filter by regex matching SQL
expect { 
  User.create(name: "Foo") 
}.to make_sql_queries(1, matching: /INSERT/)
```

#### Cache Assertions

Verify cache operations (read, write, fetch, etc.).

```ruby
# Count specific operations
expect {
  Rails.cache.read("foo")
  Rails.cache.write("bar", 1)
}.to perform_cache_operations(read: 1, write: 1)

# Count total operations
expect {
  Rails.cache.fetch("foo") { 1 }
}.to perform_cache_operations(total: 2) # 1 read (miss) + 1 write

# Filter by key matching regex
expect {
  Rails.cache.read("user:1")
  Rails.cache.read("post:1")
}.to perform_cache_operations(read: 2, matching: /user|post/)
```

#### Chaining Matchers

You can verify both SQL and Cache operations in a single block using RSpec's compound matchers.

```ruby
expect {
  User.create(name: "Alice")
  Rails.cache.write("user:alice", "data")
}.to make_sql_queries(1).and perform_cache_operations(write: 1)
```

### Multiple Cache Stores

By default, assertions use `Rails.cache`. You can specify a different store or multiple stores using `store` or `stores` options.

```ruby
# Check specific store
expect {
  my_cache.write("foo", 1)
}.to perform_cache_operations(write: 1, store: my_cache)

# Check multiple stores
expect {
  cache1.write("a", 1)
  cache2.write("b", 1)
}.to perform_cache_operations(total: 2, stores: [cache1, cache2])
```

### Minitest

Add this to your `test_helper.rb`:

```ruby
require "expect_query/minitest"
```

#### SQL Assertions

```ruby
# Exact count
assert_sql_queries(1) do
  User.first
end

# At most
assert_sql_queries(at_most: 3) do
  User.all.map(&:name)
end

# Regex matching
assert_sql_queries(1, matching: /INSERT/) do
  User.create(name: "Foo")
end
```

#### Cache Assertions

```ruby
# Specific operations
assert_cache_operations(read: 1, write: 1) do
  Rails.cache.read("foo")
  Rails.cache.write("bar", 1)
end

# Total operations
assert_cache_operations(total: 2) do
  Rails.cache.fetch("foo") { 1 }
end

# Specific store
assert_cache_operations(write: 1, store: my_cache) do
  my_cache.write("foo", 1)
end
```

#### Combined Assertions (IO Operations)

Use `assert_io_operations` to verify both SQL and Cache operations in a single block.

```ruby
assert_io_operations(sql: { count: 1 }, cache: { write: 1 }) do
  User.create(name: "Alice")
  Rails.cache.write("user:alice", "data")
end

# With options
assert_io_operations(
  sql: { count: 1, matching: /INSERT/ }, 
  cache: { read: 1, matching: /user:/ }
) do
  User.create(name: "Bob")
  Rails.cache.read("user:bob")
end
```

## Failure Messages

ExpectQuery provides detailed failure messages to help you debug.

### SQL Failure Example

```
expected to make 1 SQL queries, but made 2
Queries run:
1. SELECT * FROM users
2. UPDATE users SET name = 'foo'
```

### Cache Failure Example

```
expected to perform cache operations: total 10, 
but got: total 2
Cache operations performed:
1. read: foo
2. write: bar
```

## Development

To run tests:

```bash
bundle exec rake
```

This runs both RSpec and Minitest suites.
