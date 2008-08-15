class TrueClass ; include Selfish::ObjectInterface; end
class FalseClass; include Selfish::ObjectInterface; end

Selfish.lobby do
  # create boolean
  traits.add_slot(:boolean, _())

  # false
  false.add_slots(:as_integer => 0,
                  :compare => method(:b, :lb, :eb, :gb) {
                    b.if_true(lb, eb)
                  },
                  :if_true => method(:b1, :b2) { b2.value },
                  :not => true,
                  :_parent => traits.boolean,
                  #:store_string_if_fail => method(:fb) {
                  #  print_string
                  #},
                  :store_string_needs => false)

  # true
  true.add_slots(:as_integer => 1,
                 :compare => method(:b, :lb, :eb, :gb) {
                   b.if_true(eb, gb)
                 },
                 :if_true => method(:b1, :b2) { b1.value },
                 :not => false,
                 :_parent => traits.boolean,
                 #:store_string_if_fail => method(:fb) {
                 #  print_string
                 #},
                 :store_string_needs => true)

  # boolean
  traits.boolean.add_slots(:if_false => method(:b1, :b2) { if_true(b2, b1) },
                           :_parent => traits.ordered_oddball)

end
