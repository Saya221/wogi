hash = { nil => 1, a: 2 }
hash_without_nil_keys = hash.reject { |k, _| k.nil? }
# hash_without_nil_keys => { a: 2 }