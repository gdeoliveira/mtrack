require "set"

module MTrack
  class State
    class Context
      def initialize
        self.tracked = Set.new
        self.undefined = Set.new
      end

      def add_undefined(name)
        @undefined.add name
        name
      end

      def delete_tracked(name)
        @tracked.delete name
        name
      end

      def delete_undefined(name)
        @undefined.delete name
        name
      end

      def merge_tracked(names)
        @tracked.merge names
        names
      end

      def tracked
        @tracked.dup
      end

      def undefined
        @undefined.dup
      end

      private

      attr_writer :tracked, :undefined
    end
  end
end
