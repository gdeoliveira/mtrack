require "set"

require "mtrack/core"
require "mtrack/state"

module MTrack

  ##
  # Provides the #track_methods method to all Classes and Modules by being mixed
  # into the +Module+ class.
  module ModuleMixin
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
    # Returns a set containing the methods that were defined within the block or
    # an empty set otherwise.
    #
    #   class C
    #     track_methods do
    #       def method_1; end
    #       track_methods(:inner_group_1) { def method_2; end }
    #       def method_3; end
    #     end
    #   end  #=> #<Set: {:method_1, :method_2, :method_3}>
    def track_methods(group_name = nil, &b)
      @__mtrack__ ||= State.new
      extend Core

      if block_given?
        old_methods = public_instance_methods(false)
        begin
          module_eval(&b)
        ensure
          tracked = (public_instance_methods(false) - old_methods).map(&:to_sym).to_set
          @__mtrack__[group_name].merge_tracked tracked unless tracked.empty?
        end
      end

      tracked || Set.new
    end
  end
end
