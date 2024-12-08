---
lang: ja
link:
  - rel: 'stylesheet'
    href: 'prism.css'
---

# include 練習

```include```の練習です。

## Ruby
```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```

## HonKit
[include](source/prime.rb)

## Block Code
```include:source/prime.rb
```

## One Line
include: source/prime.rb
