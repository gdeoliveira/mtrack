require "set"

require "mtrack/state/group"

module MTrack

  ##
  # Holds the internal state of tracked methods on Modules and Classes.
  class State

    ##
    # call-seq:
    #   new(super_state = nil) => new_state
    #
    # Creates a new State instance. An optional +super_state+ parameter can be
    # passed that will be added to #super_states.
    #
    #   super_state = MTrack::State.new
    #   sub_state = MTrack::State.new(super_state)
    def initialize(super_state = nil)
      self.groups = {}
      self.super_states = super_state ? Set[super_state] : Set.new
      self.undefined = Set.new
    end

    ##
    # call-seq:
    #   state[group_name] => group
    #
    # Accepts a +group_name+ passed as a parameter.
    #
    # Returns an existing or a new group associated with +group_name+.
    def [](group_name)
      groups[group_name] ||= Group.new
    end

    ##
    # call-seq:
    #   add_super_state(state) => state
    #
    # Adds a new +state+ to the #super_states set.
    #
    # Returns passed +state+.
    def add_super_state(state)
      super_states.add state
      state
    end

    ##
    # call-seq:
    #   add_undefined(name) => name
    #
    # Adds +name+ to the #undefined methods set.
    #
    # Returns passed +name+.
    def add_undefined(name)
      undefined.add name
      name
    end

    ##
    # call-seq:
    #   delete_tracked(name) => name
    #
    # Removes method +name+ from all #groups.
    #
    # Returns passed +name+.
    def delete_tracked(name)
      groups.each {|k, v| v.delete_tracked name }
      name
    end

    ##
    # call-seq:
    #   delete_undefined(name) => name
    #
    # Removes +name+ from the #undefined methods set.
    #
    # Returns passed +name+.
    def delete_undefined(name)
      undefined.delete name
      name
    end

    ##
    # call-seq:
    #   tracked(group_name = nil) => set
    #
    # Returns a set containing the currently tracked methods for a +group_name+.
    def tracked(group_name = nil)
      ret_val = merge_super_states group_name
      ret_val.merge groups[group_name].tracked unless groups[group_name].nil?
      ret_val.subtract undefined
    end

    private

    ##
    # A Hash containing the groups defined in the current Class or Module.
    attr_accessor :groups

    ##
    # A set of references to the states of inherited Classes and included
    # Modules.
    attr_accessor :super_states

    ##
    # A set of methods that are currently undefined on this Class or Module.
    attr_accessor :undefined

    ##
    # call-seq:
    #   merge_super_states(group_name) => set
    #
    # Returns a set containing all the methods being tracked for +group_name+
    # by the #super_states.
    def merge_super_states(group_name)
      super_states.inject(Set.new) do |set, state|
        set.merge state.tracked(group_name)
      end
    end
  end
end
