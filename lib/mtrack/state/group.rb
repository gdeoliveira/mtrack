require "set"

module MTrack
  class State
    ##
    # Handles method information for each group in MTrack::State#groups.
    class Group
      ##
      # call-seq:
      #   new() => new_group
      #
      # Creates a new Group instance.
      def initialize
        self.tracked = Set.new
      end

      ##
      # call-seq:
      #   delete_tracked(name) => name
      #
      # Removes method +name+ from tracked methods.
      #
      # Returns passed +name+.
      def delete_tracked(name)
        @tracked.delete name
        name
      end

      ##
      # call-seq:
      #   merge_tracked(names) => names
      #
      # Adds method +names+ to tracked methods.
      #
      # Returns passed +names+.
      def merge_tracked(names)
        @tracked.merge names
        names
      end

      ##
      # call-seq:
      #   tracked() => new_set
      #
      # Returns a new set containing the methods currently being tracked.
      def tracked
        @tracked.dup
      end

      private

      ##
      # A set containing the method names currently being tracked.
      attr_writer :tracked
    end
  end
end
