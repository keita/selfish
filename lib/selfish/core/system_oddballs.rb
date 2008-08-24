:self_int.add_slot(:bit_size, 31)

type_sizes = {
  :bit_size => method(:type_name) { type_name.bit_size },
  :bits_per_byte => 8,
  :byte_size => method(:type_name) {
    (bit_size(type_name).to_f / bits_per_byte).ceil
  },
  :_parent => traits.oddball
}

_globals.add_slot(:type_sizes, _(type_sizes))
