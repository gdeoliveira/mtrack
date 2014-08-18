require "set"

require "mtrack/state/group"

module MTrack
  class State
    def initialize(super_state = nil)
      self.groups = {}
      self.super_states = super_state ? Set[super_state] : Set.new
      self.undefined = Set.new
    end

    def [](key)
      groups[key] ||= Group.new
    end

    def add_super_state(state)
      super_states.add state
      state
    end

    def add_undefined(name)
      undefined.add name
      name
    end

    def delete_tracked(name)
      groups.each {|k, v| v.delete_tracked name }
      name
    end

    def delete_undefined(name)
      undefined.delete name
      name
    end

    def tracked(key = nil)
      ret_val = merge_super_states key
      ret_val.merge groups[key].tracked unless groups[key].nil?
      ret_val.subtract undefined
    end

    private

    attr_accessor :groups, :super_states, :undefined

    def merge_super_states(key)
      super_states.inject(Set.new) do |set, state|
        set.merge state.tracked(key)
      end
    end
  end
end
