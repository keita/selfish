$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require "selfish"

describe "Selfish::Object" do
  it 'should read from slots' do
    obj = _(:x => 1, :y => 'a')
    obj.x.should == 1
    obj.y.should == 'a'
  end

  it 'should raise an error when reads unknown slot' do
    proc { _().x }.should.raise Selfish::SlotNotFound
  end

  it 'should write to slots' do
    obj = _(:x => 1, :y => 'a')
    obj.x = 2
    obj.x.should == 2
    obj.y = 'b'
    obj.y.should == 'b'
  end

  it 'should add a slot' do
    obj = _()
    obj.add_slot(:x)
    obj.x.should.nil
    obj.add_slot(:y, 1)
    obj.y.should == 1
  end

  it 'should call a method' do
    obj = _(:x => 1, :next => proc {|s| s.x + 1})
    obj.x.should == 1
    obj.next.should == 2
  end

  it 'should inherit parent' do
    parent = _(:x => 1, :y => 2, :sum => proc {|s| s.x + s.y })
    parent.sum.should == 3
    child = _(:x => 2, :y => 3, :_parent => parent)
    child.sum.should == 5
  end

  it 'should delegate not consult' do
    parent = _(:x => 1)
    child = _(:x => 2, :_parent => parent)
    child.x.should == 2
  end

  it 'should have parents' do
    parent1 = _()
    parent2 = _()
    parent3 = _()
    child = _(:_parent1 => parent1, :_parent2 => parent2, :_parent3 => parent3)
    child.parents.should.include parent1
    child.parents.should.include parent2
    child.parents.should.include parent3
  end

  it 'should enable to inherit multiple parents' do
    parent1 = _(:sum => proc{|s| s.x + s.y})
    parent2 = _(:subtract => proc{|s| s.x - s.y})
    child = _(:x => 1, :y => 2, :_a => parent1, :_b => parent2)
    child.sum.should == 3
    child.subtract.should == -1
  end

  it 'should raise an error when multiple ' do
    parent1 = _(:x => 1)
    parent2 = _(:x => 2)
    child = _(:_parent1 => parent1, :_parent2 => parent2)
    proc { child.x }.should.raise Selfish::ManySlotsFound
  end
end
