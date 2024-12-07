---
lang: ja
link:
  - rel: 'stylesheet'
    href: 'prism.css'
---

# Prismでの行番号表示

```Ruby``` での素数を求めるコード例です。

## Ruby

```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```
