self.extend Selfish::ObjectInterface

module Selfish
  def self.set_lobby(obj); @lobby = obj; end

  def self.lobby(&block)
    @lobby.instance_eval &block if block_given?
    @lobby
  end
end

Selfish.set_lobby self

module Kernel
  def lobby(&block)
    Selfish.lobby(&block)
  end
end

class Symbol
  include Selfish::ObjectInterface
end

require "selfish/core/init"
require "selfish/core/root_traits"
require "selfish/core/nil"
require "selfish/core/boolean"
require "selfish/core/system_oddballs"
require "selfish/core/number"
require "selfish/core/integer"
require "selfish/core/small_int"
