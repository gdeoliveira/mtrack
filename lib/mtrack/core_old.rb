require "mtrack/state"

module MTrack

  ##
  # Implements the core tracking functionality of the gem by extending those
  # Modules and Classes that use MTrack::ModuleMixin#track_methods. Additionally
  # it will extend Modules and Classes that include a Module that is tracking
  # methods and Classes that inherit from a Class that is tracking methods.
  module Core
    class << self
      private

      ##
      # call-seq:
      #   extended(submodule) => submodule
      #
      # Initializes a State variable on the Class or Module that extended Core.
      #
      # Returns passed +submodule+.
      def extended(submodule)
        submodule.instance_eval { @__mtrack__ ||= State.new }
        submodule
      end
    end

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
    # call-seq:
    #   included(submodule) => submodule
    #
    # Sets this state as a super-state of the +submodule+ (Class or Module) that
    # has included the current Module.
    #
    # Returns passed +submodule+.
    def included(submodule)
      state = @__mtrack__
      submodule.instance_eval do
        extend Core
        @__mtrack__.add_super_state state
      end
      submodule
    end

    ##
    # call-seq:
    #   inherited(submodule) => submodule
    #
    # Sets this state as a super-state of the +submodule+ (Class) that has
    # inherited from the current Class.
    #
    # Returns passed +submodule+.
    alias_method :inherited, :included

    ##
    # call-seq:
    #   method_added(name) => name
    #
    # Allows method +name+ to be displayed on #tracked_methods once again after
    # being disabled by a call to #method_undefined.
    #
    # Returns passed +name+.
    def method_added(name)
      @__mtrack__.delete_undefined name
    end

    ##
    # call-seq:
    #   method_removed(name) => name
    #
    # Stops tracking method +name+ in the current Class or Module.
    #
    # Returns passed +name+.
    def method_removed(name)
      @__mtrack__.delete_tracked name
    end

    ##
    # call-seq:
    #   method_undefined(name) => name
    #
    # Stops tracking method +name+ in the current Class or Module and prevents
    # homonymous methods tracked in super-states from being displayed as
    # #tracked_methods.
    #
    # Returns passed +name+.
    def method_undefined(name)
      @__mtrack__.delete_tracked name
      @__mtrack__.add_undefined name
    end
  end
end
