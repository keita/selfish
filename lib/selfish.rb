module Selfish
  # The module Primitives is a set of primitive methods.
  module Primitives
    def add_slots(slots)
      slots.each {|k,v| add_slot(k, v) }
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
          if @slots[selector].kind_of?(Proc)
            cont = @slots[selector].call(nil)
            if cont.kind_of?(Proc) then
              [ cont ] # method slot
            else
              [ @slots[selector] ] # data slot
            end
          else
            [ proc{ slots[selector] } ] # Literal
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
      when 0; raise SlotNotFound, name
      when 1; slots.first.call(self, *args)
      else  ; raise ManySlotsFound, name; end
    end
  end

  module SlotInterface
    UNDEF_VALUE = [:undef]
    attr_reader :slots

    # Adds new slot.
    def add_slot(name, val=nil)
      # data reader/writer
      @slots[name.to_sym] = ->(s, v = UNDEF_VALUE) {
        if v == UNDEF_VALUE then
          val
        else
          s.slots[name] = v
          s
        end
      }
    end

    # Returns parents.
    def parents
      @slots.keys.select{|name|
        name.to_s =~ /\A_.*[^=]\Z/
      }.map{|name| @slots[name].call(nil)}
    end
  end

  class SlotNotFound < StandardError; end
  class ManySlotsFound < StandardError; end

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
end

module Kernel
  # Shortcut function for creating new object.
  def _(slots={})
    ::Selfish::Object.new(slots)
  end
end

require "selfish/core"
