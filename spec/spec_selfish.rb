$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require "selfish"
require "selfish/core"

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
    obj.x! 2
    obj.x.should == 2
    obj.y! 'b'
    obj.y.should == 'b'
  end

  it 'should add a slot' do
    obj = _()
    obj.add_slot(:x)
    obj.x.should.nil
    obj.add_slot(:y, 1)
    obj.y.should == 1
  end

  it 'should make setter' do
    proc { _(:set! => method(:x) { x }) }.should.not.raise
    proc { _(:set! => method { 1 }) }.should.raise ArgumentError
    proc { _(:set! => 1) }.should.raise ArgumentError
  end

  it 'should call a method' do
    obj = _(:x => 1, :next => method { x + 1 })
    obj.x.should == 1
    obj.next.should == 2
  end

  it 'should call setter in method' do
    obj = _(:x => 1, :next => method { x! (x + 1) })
    obj.x.should == 1
    obj.next.x.should == 2
  end

  it 'should inherit parent' do
    parent = _(:x => 1, :y => 2, :sum => method { x + y })
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
    child.parents.should == [parent1, parent2, parent3]
  end

  it 'should enable to inherit multiple parents' do
    parent1 = _(:sum => method { x + y })
    parent2 = _(:subtract => method { x - y })
    child = _(:x => 1, :y => 2, :_a => parent1, :_b => parent2)
    child.sum.should == 3
    child.subtract.should == -1
  end

  it 'should raise an error when inherit multiplely' do
    parent1 = _(:x => 1)
    parent2 = _(:x => 2)
    child = _(:_parent1 => parent1, :_parent2 => parent2)
    proc { child.x }.should.raise Selfish::ManySlotsFound
  end
end

describe "Selfish::MethodObject" do
  it 'should know arity' do
    method(:x, :y, :z){}.arity.should == 3
  end

  it 'should call recuirsively' do
    _(:res => method(:n){
        n > 0 ? res(n - 1) : "end"
      }).res(10).should == "end"
  end

  it 'should clone' do
    obj = method(:x){ x + 1 }.clone
    obj.should.kind_of Selfish::MethodObject
  end
end

describe "Selfish::BlockObject" do
  it 'should create blocks' do
    block { 1 + 1 }.should.kind_of Selfish::BlockObject
    proc{ block(:x) { x + 1 } }.should.not.raise
  end

  it 'should interpret arguments' do
    _(:result => method {
        (block(:x) { x + 1 }).value(10)
      }).result.should == 11
  end

  it 'should delegate from method' do
    _(:res => method { block { x }.value }, :x => 1).res.should == 1
  end

  it 'should call recuirsively' do
    _(:res => method(:n) {
        n > 0 ? block { res(n - 1) }.value : "end"
      }).res(10).should == "end"
  end

  it 'should clone' do
    obj = block(:x) { x + 1 }.clone
    obj.should.kind_of Selfish::BlockObject
    obj.value(2).should == 3
  end
end
