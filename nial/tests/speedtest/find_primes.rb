def is_prime(num)
  for number in (2..num-1)
    if num % number == 0 then return false end
  end
  return true
end

def find_primes(limit)
  primes = Array.new
  for number in (2..limit)
    if is_prime(number) then primes << number end
  end
  return primes
end

find_primes(1000)
