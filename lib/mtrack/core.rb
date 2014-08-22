require "mtrack/state"

module MTrack

  ##
  # Implements the core tracking functionality of the gem by extending those
  # Modules and Classes that use MTrack::ModuleMixin#track_methods. Additionally
  # it will extend Modules and Classes that include a Module that is tracking
  # methods and Classes that inherit from a Class that is tracking methods.
  module Core

    ##
    # call-seq:
    #   tracked_methods(group_name = nil) => set
    #
    # Returns a set containing the currently tracked methods for a +group_name+.
    #
    #   class C
    #     track_methods :my_group do
    #       def method_1; end
    #       def method_2; end
    #     end
    #   end
    #
    #   C.tracked_methods :my_group  #=> #<Set: {:method_1, :method_2}>
    def tracked_methods(group_name = nil)
      @__mtrack__.tracked group_name
    end

    private

    ##
    # Sets this state as a super-state of the Class or Module that has included
    # the current Module.
    def included(submodule)
      state = @__mtrack__
      submodule.instance_eval do
        if @__mtrack__.nil?
          @__mtrack__ = State.new(state)
          extend Core
        else
          @__mtrack__.add_super_state state
        end
      end
    end

    ##
    # Sets this state as a super-state of the Class that has inherited from the
    # current Class.
    def inherited(subclass)
      state = @__mtrack__
      subclass.instance_eval { @__mtrack__ = State.new(state) }
    end

    ##
    # Allows method +name+ to be displayed on #tracked_methods once again after
    # being disabled by a call to #method_undefined.
    def method_added(name)
      @__mtrack__.delete_undefined name
    end

    ##
    # Stops tracking method +name+ in the current Class or Module.
    def method_removed(name)
      @__mtrack__.delete_tracked name
    end

    ##
    # Stops tracking method +name+ in the current Class or Module and prevents
    # homonymous methods tracked in super-states from being displayed as
    # #tracked_methods.
    def method_undefined(name)
      @__mtrack__.delete_tracked name
      @__mtrack__.add_undefined name
    end
  end
end
