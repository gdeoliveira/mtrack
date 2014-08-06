require "set"

require "mtrack/state/context"

module MTrack
  class State
    def initialize(super_state = nil)
      self.context = {}
      self.super_states = super_state ? Set[super_state] : Set.new
    end

    def [](key)
      context[key] ||= Context.new
    end

    def add_super_state(state)
      super_states.add state
      state
    end

    def add_undefined(name)
      context.each {|k, v| v.add_undefined name }
      name
    end

    def delete_tracked(name)
      context.each {|k, v| v.delete_tracked name }
      name
    end

    def delete_undefined(name)
      context.each {|k, v| v.delete_undefined name }
      name
    end

    def methods(key = nil)
      ret_val = merge_super_states key
      unless context[key].nil?
        ret_val.merge(context[key].tracked).subtract(context[key].undefined)
      end

      ret_val
    end

    private

    attr_accessor :context, :super_states

    def merge_super_states(key)
      super_states.each_with_object(Set.new) do |state, set|
        set.merge state.methods(key)
      end
    end
  end
end
