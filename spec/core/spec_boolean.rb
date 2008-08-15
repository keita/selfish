$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
require "selfish"
require "selfish/core"

describe "false" do
  it "#as_integer" do
    false.as_integer.should == 0
  end

  it "#compare" do
    false.compare(false, 1, 2, 3).should == 2
    false.compare(true, 1, 2, 3).should == 1
  end

  it "#if_true" do
    false.if_true(1, 2).should == 2
    false.if_true(block{1}, block{2}).should == 2
    false.if_true(1).should.nil
  end

  it "#if_false" do
    false.if_false(1, 2).should == 1
    false.if_false(1).should == 1
  end

  it "#not" do
    false.not.should == true
  end
end

describe "true" do
  it "#as_integer" do
    true.as_integer.should == 1
  end

  it "#compare" do
    true.compare(true, 1, 2, 3).should == 2
    true.compare(false, 1, 2, 3).should == 3
  end

  it "#if_true" do
    true.if_true(1, 2).should == 1
    true.if_true(block{1}, block{2}).should == 1
    true.if_true(1).should == 1
  end

  it "#if_false" do
    true.if_false(1, 2).should == 2
    true.if_false(1).should == nil
  end

  it "#not" do
    true.not.should == false
  end
end
