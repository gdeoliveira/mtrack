require "mtrack/state"

module MTrack
  module Mixin
    class << self
      private

      def extended(submodule)
        submodule.instance_eval { @__mtrack__ ||= State.new }
        submodule
      end

      def newly_defined_methods(mod, old_methods)
        (mod.public_instance_methods(false) - old_methods).map(&:to_sym).to_set
      end

      def save_tracked_methods(mod, group_name, tracked)
        mod.instance_variable_get(:@__mtrack__)[group_name].merge_tracked tracked unless tracked.empty?
        nil
      end

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

    public

    def tracked_methods(group_name = nil)
      @__mtrack__.tracked group_name
    end

    private

    def included(submodule)
      state = @__mtrack__
      submodule.instance_eval do
        extend Mixin
        @__mtrack__.add_super_state state
      end
      submodule
    end

    alias_method :inherited, :included

    def method_added(name)
      @__mtrack__.delete_undefined name
    end

    def method_removed(name)
      @__mtrack__.delete_tracked name
    end

    def method_undefined(name)
      @__mtrack__.delete_tracked name
      @__mtrack__.add_undefined name
    end

    def track_methods(group_name = nil, &b)
      Mixin.send(:track_methods_for, self, group_name, &b)
    end
  end
end
