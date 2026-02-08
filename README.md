# ExpectQuery

`expect_query` provides Rails 8.0+ compatible assertions and matchers for counting SQL queries and Cache operations. It supports both RSpec and Minitest.

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

```ruby
expect { 
  User.first 
}.to make_sql_queries(1)

expect { 
  User.create(name: "Foo") 
}.to make_sql_queries(1, matching: /INSERT/)

expect {
  # ...
}.to make_sql_queries(at_most: 3)
```

#### Cache Assertions

```ruby
expect {
  Rails.cache.read("foo")
  Rails.cache.write("bar", 1)
}.to perform_cache_operations(read: 1, write: 1)

expect {
  Rails.cache.fetch("foo") { 1 }
}.to perform_cache_operations(total: 2) # read + write (if miss)
```

### Multiple Cache Stores

By default, assertions use `Rails.cache` (if available). You can specify a different store or multiple stores using `store` or `stores` options.

```ruby
# RSpec
expect {
  my_cache.write("foo", 1)
}.to perform_cache_operations(write: 1, store: my_cache)

expect {
  cache1.write("a", 1)
  cache2.write("b", 1)
}.to perform_cache_operations(total: 2, stores: [cache1, cache2])
```

```ruby
# Minitest
assert_cache_operations(write: 1, store: my_cache) do
  my_cache.write("foo", 1)
end
```

```ruby
require "expect_query/minitest"
```

#### SQL Assertions

```ruby
assert_sql_queries(1) do
  User.first
end
```

#### Cache Assertions

```ruby
assert_cache_operations(read: 1, write: 1) do
  Rails.cache.read("foo")
  Rails.cache.write("bar", 1)
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

