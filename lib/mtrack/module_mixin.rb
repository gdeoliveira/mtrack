require "set"

require "mtrack/core"
require "mtrack/state"

module MTrack
  module ModuleMixin
    private

    def track_methods(*context, &b)
      @__mtrack__ ||= State.new
      extend Core

      if block_given?
        old_methods = public_instance_methods(false)
        begin
          module_eval(&b)
        ensure
          tracked = (public_instance_methods(false) - old_methods).to_set
          unless tracked.empty?
            context = [nil] if context.empty?
            context.each do |key|
              @__mtrack__[key].merge_tracked tracked
            end
          end
        end
      end

      tracked || Set.new
    end
  end
end
