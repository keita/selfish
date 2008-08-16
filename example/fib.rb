require "selfish"
require "selfish/core"

Selfish::lobby do
  add_slot(:fib, method(:n) {
             (2 < n).if_true(block { (fib n - 1) + (fib n - 2) }, n)
           })
  0.upto(10) {|i| puts (fib i) }
end
