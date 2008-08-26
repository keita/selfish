require "continuation" if RUBY_VERSION[0..2] == "1.9"

module Selfish
  # The module Primitives is a set of primitive methods.
  module Primitives
    def add_slots(slots)
      slots.each {|k,v| add_slot(k, v) }
    end

    def clone
      obj = _()
      slots.each {|k,v| obj.add_slot(k, v) }
      return obj
    end

    def value
      self
    end
  end

  # Delegation represents the inheritance mechaism for Selfish objects.
  # This is just same as Self's.
  module Delegation
    # Lookup parents behaviors.
    # See Self Reference manual 2.3.8.
    def parent_lookup(selector, visited)
      parents.inject([]) do |res, parent|
        res += parent.lookup(selector, visited)
        res
      end
    end

    # The lookup algorithm.
    # See Self Reference manual 2.3.8.
    def lookup(selector, visited)
      if visited.include?(self) then []
      else
        visited << self
        if slots.has_key?(selector)
          if slots[selector].kind_of?(MethodObject)
            [ slots[selector] ]
          else
            [ proc { slots[selector] } ]
          end
        else
          parent_lookup(selector, visited)
        end
      end
    end

    private

    # Message send.
    # See Self reference manual 2.3.7.
    def send(name, args)
      results = lookup(name, [])
      case results.size
      when 0; raise SlotNotFound.new(self, name)
      when 1; results.first.call(self, *args)
      else  ; raise ManySlotsFound.new(self, name); end
    end

    def method_missing(name, *args)
      send(name, args)
    end
  end

  module SlotInterface
    # Returns slot table of the object.
    def slots
      @slots ||= {}
    end

    # Adds new slot or updates.
    def add_slot(name, val=nil)
      # slots with postfix "!" should be setter methods
      if name.to_s =~ /!\Z/
        unless val.kind_of?(MethodObject) and val.arity != 0
          raise ArgumentError
        end
      end

      # set the slot
      slots[name.to_sym] = val

      # data writer
      unless val.kind_of?(MethodObject)
        add_slot("#{name}!".to_sym, method(:x) {
                   (_self.add_slot(name, x); _self)
                 })
      end
    end

    # Returns parents.
    def parents
      slots.keys.select{|name|
        name.to_s =~ /\A_[^_]*[^!]\Z/
      }.map{|name| @slots[name] }
    end
  end

  module ObjectInterface
    include Delegation
    include SlotInterface
    include Primitives
  end

  class SlotError < StandardError
    def initialize(reciever, slot_name)
      @reciever = reciever
      @slot_name = slot_name
    end

    def message
      "slot_name: #{@slot_name} reciever:#{@reciever.inspect}"
    end
  end

  class SlotNotFound < SlotError; end
  class ManySlotsFound < SlotError; end

  class Object
    include ObjectInterface

    def initialize(slots = {})
      @slots = {}
      add_slots(slots)
    end
  end

  # MethodObject is the class for method slot.
  # It's slot "self" is the reciever and delegates other methods.
  class MethodObject < Object
    def initialize(*keys, &block)
      super({})
      @slots[:__keys__] = keys
      @slots[:__code__] = block
    end

    def clone
      return self.class.new(*__keys__, &__code__)
    end

    # Returns the number of arity.
    def arity
      __keys__.size
    end

    def call(reciever, *args)
      clone.instance_eval do
        # set self
        slots[:_self] =
          reciever.kind_of?(MethodObject) ? reciever._self : reciever
        slots[:__self__] = slots[:_self]

        eval_code(*args)
      end
    end

    private

    def eval_code(*args)
      # set arguments
      if __keys__[0].kind_of?(Hash)
        # with keywords
        __keys__[0].each do |k, v|
          @slots[v] = args[0][k]
        end
      else
        # without keywords
        @slots[:args_] = args
        0.upto(arity - 1) do |idx|
          @slots[__keys__[idx]] = args[idx]
        end
      end

      # set writer method if the slot value is nil
      @slots.select{|k, v| v.nil? }.each do |k, v|
        m = self
        @slots[:"#{k}!"] = method(:x){
          m.add_slot(k, x); __self__
        } if @slots[k].nil?
      end

      __eval__
    end

    # can catch "return"
    def __eval__
      ::Kernel.callcc do |c|
        @slots[:__return__] = method{ c.call(*args_) }
        instance_eval(&__code__)
      end
    end
  end

  class BlockMethod < MethodObject
    def initialize(parent, *keys, &block)
      super(*keys, &block)
      @slots[:_parent] = parent
    end

    def clone
      obj = super
      obj.slots[:_parent] = _parent
    end

    def call(*args)
      instance_eval { eval_code(*args) }
    end

    private

    # cannot catch "__return__"
    def __eval__
      instance_eval(&__code__)
    end
  end

  class BlockObject < Object
    undef_method :value

    def initialize(parent, *keys, &block)
      block_method = BlockMethod.new(parent, *keys, &block)
      super(:lexical_parent => parent, :block_method => block_method)

      # method "value"
      add_slot(:value, method { block_method.call(*args_) })
    end

    def clone
      return BlockObject.new(slots[:lexical_parent],
                             *slots[:block_method].__keys__,
                             &slots[:block_method].slots[:__code__])
    end
  end
end

module Kernel
  # Shortcut function for creating new object.
  def _(slots={})
    ::Selfish::Object.new(slots)
  end

  def method(*keys, &block)
    ::Selfish::MethodObject.new(*keys, &block)
  end

  def block(*keys, &block)
    ::Selfish::BlockObject.new(self, *keys, &block)
  end
end
