##
# MTrack extends the functionality of Modules and Classes and enables them to
# define public methods within groups. These methods can then be queried back
# even through a hierarchy of inclusion and/or inheritance.
#
#   module M
#     track_methods { def method_1; end }
#   end
#
#   class C
#     include M
#     track_methods { def method_2; end }
#   end
#
#   class D < C
#     track_methods { def method_3; end }
#   end
#
#   D.tracked_methods  #=> #<Set: {:method_1, :method_2, :method_3}>
module MTrack

  # Current version of MTrack.
  VERSION = "0.0.2"
end
