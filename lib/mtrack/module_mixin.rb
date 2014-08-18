require "set"

require "mtrack/core"
require "mtrack/state"

module MTrack
  module ModuleMixin
    private

    def track_methods(*groups, &b)
      @__mtrack__ ||= State.new
      extend Core

      if block_given?
        old_methods = public_instance_methods(false)
        begin
          module_eval(&b)
        ensure
          tracked = (public_instance_methods(false) - old_methods).map(&:to_sym).to_set
          unless tracked.empty?
            groups = [nil] if groups.empty?
            groups.each do |group|
              @__mtrack__[group].merge_tracked tracked
            end
          end
        end
      end

      tracked || Set.new
    end
  end
end
