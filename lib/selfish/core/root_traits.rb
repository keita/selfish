#
# This is Selfish version of objects/core/rootTraits.self.
#

# make initial objects
Selfish.lobby.add_slots(:mixins => _(), :traits => _(), :_globals => _())

Selfish.lobby do
  # mixins clonable
  mixins.add_slots(:clonable => _())
  mixins.clonable.add_slots(:copy => method { _self.clone })

  # mixins identity
  mixins.add_slots(:identity => _())

  # mixins oddball
  mixins.add_slots(:oddball => _(:copy => method { _self }))

  # mixins ordered
  mixins.add_slots(:ordered => _(:descendant_responsibilities => _()))

  # mixins unordered
  mixins.add_slots(:unordered => _(:descendant_responsibilities => _()))

  # traits clonable
  traits.add_slots(:clonable => _())
  traits.clonable.add_slots(:_cloning => mixins.clonable,
                            :_comparing => mixins.identity,
                            :_ordering => mixins.unordered,
                            :_parent => Selfish.lobby)

  # traits oddball
  traits.add_slots(:oddball => _())
  traits.oddball.add_slots(:_cloning => mixins.oddball,
                           :_comparing => mixins.identity,
                           :_ordering => mixins.unordered,
                           :_parent => Selfish.lobby)

  # traits ordered_clonable
  traits.add_slots(:ordered_clonable => _())
  traits.ordered_clonable.add_slots(:_cloning => mixins.clonable,
                                    :_ordering => mixins.ordered,
                                    :_parent => Selfish.lobby)

  # traits ordered_oddball
  traits.add_slots(:ordered_oddball => _())
  traits.ordered_oddball.add_slots(:_cloning => mixins.oddball,
                                   :_ordering => mixins.ordered,
                                   :_parent => Selfish.lobby)
end
