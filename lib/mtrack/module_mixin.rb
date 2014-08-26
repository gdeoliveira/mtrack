require "set"

require "mtrack/core"

module MTrack

  ##
  # Provides the #track_methods method to all Classes and Modules by being mixed
  # into the +Module+ class.
  module ModuleMixin
    class << self
      private

      ##
      # call-seq:
      #   newly_defined_methods(mod, old_methods) => set
      #
      # Calculates the difference between +mod+'s currently defined public
      # methods and +old_methods+.
      #
      # Returns a set with the result.
      def newly_defined_methods(mod, old_methods)
        (mod.public_instance_methods(false) - old_methods).map(&:to_sym).to_set
      end

      ##
      # call-seq:
      #   save_tracked_methods(mod, group_name, tracked)
      #
      # Saves +tracked+ methods for +mod+ under a +group_name+.
      def save_tracked_methods(mod, group_name, tracked)
        mod.instance_variable_get(:@__mtrack__)[group_name].merge_tracked tracked unless tracked.empty?
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
          mod.module_eval &b if block_given?
        ensure
          tracked = newly_defined_methods(mod, old_methods)
          save_tracked_methods(mod, group_name, tracked)
        end

        tracked
      end
    end

    private

    ##
    # call-seq:
    #   track_methods(group_name = nil) => set
    #   track_methods(group_name = nil) {|| ... } => set
    #
    # Sets up an MTrack::State instance for this Class or Module and extends it
    # using MTrack::Core.
    #
    # If a block is provided all the methods defined within the block will be
    # tracked under the optional +group_name+ parameter.
    #
    # Returns a set containing the methods that were defined within the block.
    #
    #   class C
    #     track_methods do
    #       def method_1; end
    #       track_methods(:inner_group_1) { def method_2; end }
    #       def method_3; end
    #     end
    #   end  #=> #<Set: {:method_1, :method_2, :method_3}>
    def track_methods(group_name = nil, &b)
      extend Core
      ModuleMixin.send(:track_methods_for, self, group_name, &b)
    end
  end
end
