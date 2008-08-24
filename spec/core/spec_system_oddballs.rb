$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
require "selfish"
require "selfish/core"

type_sizes = Selfish.lobby.type_sizes

describe "globals.type_size" do
  it '#bit_size' do
    type_sizes.bit_size(:selfish_int).should == 31
  end

  it '#bits_per_byte' do
    type_sizes.bits_per_byte.should == 8
  end

  it '#byte_size' do
    type_sizes.byte_size(:selfish_int).should == 4
  end
end
