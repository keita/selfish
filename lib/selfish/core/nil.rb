class NilClass
  include Selfish::ObjectInterface
end

Selfish.lobby do
  nil.add_slots(:_parent => traits.oddball,
                :store_string_fail => method(:fb) { 'nil' },
                :store_string_needs => nil)
end
