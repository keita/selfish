module Selfish
  # The module Primitives is a set of primitive methods.
  module Primitives
    def add_slots(slots)
      slots.each {|k,v| add_slot(k, v) }
    end

    def clone
      obj = _()
      @slots.each {|k,v| obj.add_slot(k, v) }
      return obj
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
        if @slots.has_key?(selector)
          if @slots[selector].kind_of?(MethodObject)
            [ @slots[selector] ]
          else
            [ proc { @slots[selector] } ]
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
      slots = lookup(name, [])
      case slots.size
      when 0; raise SlotNotFound.new(self, name)
      when 1; slots.first.call(self, *args)
      else  ; raise ManySlotsFound.new(self, name); end
    end
  end

  module SlotInterface
    # Adds new slot or updates.
    def add_slot(name, val=nil)
      # slots with postfix "!" should be setter methods
      if name.to_s =~ /!\Z/
        unless val.kind_of?(MethodObject) and val.arity != 0
          raise ArgumentError
        end
      end

      # set the slot
      @slots[name.to_sym] = val

      # data writer
      unless val.kind_of?(MethodObject)
        add_slot("#{name}!".to_sym, method(:x) {
                   (_self.add_slot(name, x); _self)
                 })
      end
    end

    # Returns parents.
    def parents
      @slots.keys.select{|name|
        name.to_s =~ /\A_.*[^!]\Z/
      }.map{|name| @slots[name] }
    end
  end

  class SlotError < StandardError
    def initialize(reciever, slot_name)
      @reciever = reciever
      @slot_name = slot_name
    end

    def message
      "reciever:#{@reciever.inspect} slot_name: #{@slot_name}"
    end
  end

  class SlotNotFound < SlotError; end
  class ManySlotsFound < SlotError; end

  class Object
    include Delegation
    include SlotInterface
    include Primitives

    def initialize(slots = {})
      @slots = {}
      add_slots(slots)
    end

    private

    def method_missing(name, *args)
      send(name, args)
    end
  end

  # MethodObject is the class for method slot.
  # It's slot "self" is the reciever and delegates other methods.
  class MethodObject < Object
    undef_method :add_slot

    def initialize(*keywords, &block)
      super({})
      @keywords = keywords
      @block = block
    end

    # Returns the number of arity.
    def arity
      @keywords.size
    end

    def call(reciever, *args)
      # set self
      @slots[:_self] =
        reciever.kind_of?(MethodObject) ? reciever._self : reciever

      # set arguments
      @args = args
      0.upto(@keywords.size-1) do |idx|
        @slots[@keywords[idx]] = args[idx]
      end
      # eval
      instance_eval(&@block)
    end
  end

  class BlockMethod < MethodObject
    def initialize(parent, *keys, &block)
      super(*keys, &block)
      @slots[:_parent] = parent
    end

    def call(*args)
      super(nil, *args)
    end
  end

  class BlockObject < Object
    def initialize(s, *keys, &block)
      super(:lexical_parent => s)
      block_method = BlockMethod.new(s, *keys, &block)

      # method "value"
      add_slot(:value, method { block_method.call(*@args) })
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
