require "mtrack/state"

module MTrack
  module Core
    def tracked_methods(key = nil)
      @__mtrack__.tracked key
    end

    private

    def included(submodule)
      state = @__mtrack__
      submodule.instance_eval do
        if @__mtrack__.nil?
          @__mtrack__ = State.new(state)
        else
          @__mtrack__.add_super_state state
        end
      end
    end

    def inherited(subclass)
      state = @__mtrack__
      subclass.instance_eval { @__mtrack__ = State.new(state) }
    end

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
  end
end
