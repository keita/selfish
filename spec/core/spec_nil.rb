$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
require "selfish"
require "selfish/core"

describe "NilClass" do
  it 'should have slots' do
    nil.add_slots(:x => 1, :y => 2, :sum => method { x + y })
    nil.x.should == 1
    nil.y.should == 2
    nil.sum.should == 3
  end

  it 'should be a child of traits.oddball' do
    nil._parent.should == lobby.traits.oddball
  end

  it '#store_string_fail' do
    nil.store_string_fail.should == 'nil'
  end
end
