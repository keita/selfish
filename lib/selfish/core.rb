module Selfish
  def self.lobby(&block)
    @lobby ||= Object.new
    @lobby.instance_eval &block if block_given?
    @lobby
  end
end

module Kernel
  def lobby(&block)
    Selfish.lobby(&block)
  end
end

require "selfish/core/init"
require "selfish/core/root_traits"
require "selfish/core/nil"
require "selfish/core/boolean"
require "selfish/core/number"
