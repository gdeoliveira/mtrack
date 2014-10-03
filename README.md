# MTrack

[![Gem Version](http://img.shields.io/gem/v/mtrack.svg)][gem]
[![Build Status](http://img.shields.io/travis/gdeoliveira/mtrack.svg)][travis]
[![Code Climate](http://img.shields.io/codeclimate/github/gdeoliveira/mtrack.svg)][codeclimate]
[![Test Coverage](http://img.shields.io/codeclimate/coverage/github/gdeoliveira/mtrack.svg)][codeclimate]
[![Dependency Status](https://gemnasium.com/gdeoliveira/mtrack.svg)][gemnasium]
[![Inline docs](http://inch-ci.org/github/gdeoliveira/mtrack.svg?branch=master)][inch-ci]

[gem]: https://rubygems.org/gems/mtrack
[travis]: http://travis-ci.org/gdeoliveira/mtrack
[codeclimate]: https://codeclimate.com/github/gdeoliveira/mtrack
[gemnasium]: https://gemnasium.com/gdeoliveira/mtrack
[gemnasium]: https://gemnasium.com/gdeoliveira/mtrack#development-dependencies
[inch-ci]: http://inch-ci.org/github/gdeoliveira/mtrack

MTrack extends the functionality of Modules and Classes and enables them to
define public methods within groups. These methods can then be queried back even
through a hierarchy of inclusion and/or inheritance.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "mtrack"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mtrack

## Usage

To track a group of methods within a Module (or a Class).

```ruby
require "mtrack"

module Stooges
  extend MTrack::Mixin

  def shemp; end

  track_methods do
    def curly; end
    def larry; end
    def moe; end
  end
end

Stooges.tracked_methods  #=> #<Set: {:curly, :larry, :moe}>
```

Methods can be grouped using an optional name.

```ruby
require "mtrack"

module Numbers
  extend MTrack::Mixin

  def zero; end

  track_methods :integers do
    track_methods :odd do
      def one; end
      def three; end
    end

    track_methods :even do
      def two; end
      def four; end
    end
  end
end

Numbers.tracked_methods :integers  #=> #<Set: {:one, :three, :two, :four}>
Numbers.tracked_methods :odd       #=> #<Set: {:one, :three}>
Numbers.tracked_methods :even      #=> #<Set: {:two, :four}>
```

Tracked methods can be carried to other Modules and Classes via inclusion and
inheritance.

```ruby
# We're using the previously defined Stooges and Numbers modules here.

class MyClass
  include Stooges
  include Numbers
end

class MySubClass < MyClass
end

MySubClass.tracked_methods            #=> #<Set: {:curly, :larry, :moe}>
MySubClass.tracked_methods :integers  #=> #<Set: {:one, :three, :two, :four}>
```

## Example

### Simple State Machine

We'll create a simple state machine using MTrack. First, let's create an
abstraction for the state machine.

```ruby
require "mtrack"

class SimpleStateMachine
  extend MTrack::Mixin

  class << self
    private

    alias_method :allow_while, :track_methods

    def actions(transitions)
      transitions.each do |action, state|
        define_method action, transition_implementation(action, state)
      end
    end

    def transition_implementation(action, new_state)
      proc do
        if self.class.tracked_methods(state).include? action
          self.state = new_state
          state_changed action
        else
          state_not_changed action
        end
      end
    end
  end

  def initialize(state)
    self.state = state
  end

  private

  attr_accessor :state
end
```

And now we'll implement a box that can be either _locked_, _closed_ or _open_.

```ruby
class Box < SimpleStateMachine
  def initialize
    super :locked
  end

  allow_while(:locked) { actions :unlock => :closed }
  allow_while(:closed) { actions :lock => :locked, :open => :open }
  allow_while(:open) { actions :close => :closed }

  def look
    "The box is #{state}."
  end

  private

  def state_changed(action)
    "You #{action} the box."
  end

  def state_not_changed(action)
    "You can't #{action} the box while it is #{state}!"
  end
end
```

A sample output for our box could be:

```ruby
box = Box.new  #=> #<Box:0x007f00f0be30c8 @state=:locked>
box.look       #=> "The box is locked."
box.open       #=> "You can't open the box while it is locked!"
box.unlock     #=> "You unlock the box."
box.look       #=> "The box is closed."
box.open       #=> "You open the box."
box.lock       #=> "You can't lock the box while it is open!"
box.close      #=> "You close the box."
box.lock       #=> "You lock the box."
```

## Contributing

1. Fork it ( https://github.com/gdeoliveira/mtrack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
