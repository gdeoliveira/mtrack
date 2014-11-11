module MTrack
  ##
  # This module is extended by Mixin and all custom extensions of Mixin. You should not extend this module directly,
  # instead simply include Mixin into your custom extension:
  #
  #   module MyExtension
  #     include MTrack::Mixin
  #     # Define custom methods here.
  #   end
  #
  #   module M
  #     extend MyExtension
  #     # You can use MTrack's and MyExtension's methods here.
  #   end
  #
  # If you're overriding the +extended+ or +included+ methods in your custom extension always make sure to call +super+,
  # so MTrack can be properly initialized.
  module Extension
    private

    ##
    # call-seq:
    #   extended(submodule) => submodule
    #
    # Initializes a State variable on the Class or Module that extended Mixin.
    #
    # Returns passed +submodule+.
    def extended(submodule)
      super
      submodule.instance_eval { @__mtrack__ ||= State.new }
      submodule
    end

    ##
    # call-seq:
    #   included(submodule) => submodule
    #
    # Initializes +submodule+ as a custom extension of Mixin. The new custom extension +submodule+ can then be extended
    # by a Class or Module just like Mixin, or included further to generate other, more specific custom extensions.
    #
    # Returns passed +submodule+.
    def included(submodule)
      super
      submodule.instance_eval { extend Extension }
      submodule
    end
  end
end
