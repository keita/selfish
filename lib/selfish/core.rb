module Selfish
  def self.lobby(&block)
    @lobby ||= Object.new
    @lobby.instance_eval &block if block_given?
    @lobby
  end
end

# make initial objects
Selfish.lobby.add_slots(:mixins => _(), :traits => _(), :_globals => _())

Selfish.lobby do
  mixins.add_slots(:clonable => _())
  mixins.clonable.add_slots(:copy => proc {|s| s.clone })

  traits.add_slots(:clonable => _())
  traits.clonable.add_slots(:_cloning => mixins.clonable,
                            :_parent => Selfish.lobby)
end
