require "mtrack/extension"
require "mtrack/state"

module MTrack
  ##
  # This module provides the #track_methods method to Classes or Modules that
  # extend it. It also enables the extended Class or Module to pass tracked
  # methods to its subclasses and submodules.
  module Mixin
    extend Extension

    class << self
      private

      ##
      # call-seq:
      #   init_heir(submodule, state) => submodule
      #
      # Sets +state+ as the super-state of +submodule+ (Class or Module).
      #
      # Returns passed +submodule+.
      def init_heir(submodule, state)
        submodule.instance_eval do
          extend Mixin
          @__mtrack__.add_super_state state
        end
        submodule
      end

      ##
      # call-seq:
      #   newly_defined_methods(mod, old_methods) => set
      #
      # Calculates the difference between +mod+'s currently defined public
      # methods and +old_methods+.
      #
      # Returns a set with the result.
      def newly_defined_methods(mod, old_methods)
        (mod.public_instance_methods(false) - old_methods).to_set
      end

      ##
      # call-seq:
      #   save_tracked_methods(mod, group_name, tracked) => nil
      #
      # Saves +tracked+ methods for +mod+ under a +group_name+.
      #
      # Returns a +nil+ value.
      def save_tracked_methods(mod, group_name, tracked)
        mod.instance_variable_get(:@__mtrack__)[group_name].merge_tracked tracked unless tracked.empty?
        nil
      end

      ##
      # call-seq:
      #   track_methods_for(mod, group_name) => set
      #   track_methods_for(mod, group_name) {|| ... } => set
      #
      # Sets up an MTrack::State instance for +mod+.
      #
      # If a block is provided all the methods defined within the block will be
      # tracked under the +group_name+ parameter.
      #
      # Returns a set containing the methods that were defined within the block.
      def track_methods_for(mod, group_name, &b)
        old_methods = mod.public_instance_methods false

        begin
          mod.module_eval(&b) if block_given?
        ensure
          tracked = newly_defined_methods(mod, old_methods)
          save_tracked_methods(mod, group_name, tracked)
        end

        tracked
      end
    end

    ##
    # call-seq:
    #   tracked_methods(group_name = nil) => set
    #
    # Returns a set containing the currently tracked methods for a +group_name+.
    #
    #   class C
    #     extend MTrack::Mixin
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
      super
      Mixin.send(:init_heir, submodule, @__mtrack__)
    end

    ##
    # call-seq:
    #   inherited(submodule) => submodule
    #
    # Sets this state as a super-state of the +submodule+ (Class) that has
    # inherited from the current Class.
    #
    # Returns passed +submodule+.
    def inherited(submodule)
      super
      Mixin.send(:init_heir, submodule, @__mtrack__)
    end

    ##
    # call-seq:
    #   method_added(name) => name
    #
    # Allows method +name+ to be displayed on #tracked_methods once again after
    # being disabled by a call to #method_undefined.
    #
    # Returns passed +name+.
    def method_added(name)
      super
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
      super
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
      super
      @__mtrack__.delete_tracked name
      @__mtrack__.add_undefined name
    end

    ##
    # call-seq:
    #   track_methods(group_name = nil) => set
    #   track_methods(group_name = nil) {|| ... } => set
    #
    # If a block is provided all the methods defined within the block will be
    # tracked under the optional +group_name+ parameter.
    #
    # Returns a set containing the methods that were defined within the block.
    #
    #   class C
    #     extend MTrack::Mixin
    #     track_methods do
    #       def method_1; end
    #       track_methods(:inner_group_1) { def method_2; end }
    #       def method_3; end
    #     end
    #   end  #=> #<Set: {:method_1, :method_2, :method_3}>
    def track_methods(group_name = nil, &b)
      Mixin.send(:track_methods_for, self, group_name, &b)
    end
  end
end
