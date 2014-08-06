require "set"

module MTrack
  class State
    class Context
      def initialize
        self.tracked = Set.new
      end

      def delete_tracked(name)
        @tracked.delete name
        name
      end

      def merge_tracked(names)
        @tracked.merge names
        names
      end

      def tracked
        @tracked.dup
      end

      private

      attr_writer :tracked
    end
  end
end
