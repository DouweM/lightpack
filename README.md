# lightpack

A Ruby library for communicating with your [Lightpack](http://lightpack.tv).

## Installation

```sh
gem install lightpack
```

Or in your Gemfile:

```ruby
gem "lightpack"
```

## Usage

```ruby
require "lightpack"

# You can open a connection to the Lightpack that will live for the duration of the block using `.open`:
Lightpack.open do |lightpack|
  # Use `lightpack` as described below.
end

# If you want a little more control over opening and closing the connection, just use `.new`: 
lightpack = Lightpack.new("127.0.0.1", 3636, "api_key")
# "127.0.0.1" and 3636 are the default host and port and can be omitted as in the `.open` example. 
# The third parameter is the optional api key, which you need to set 
# if you've set up your Lightpack to require authentication.

# You can then explicitly open a connection to the lightpack. 
# You're responsible for closing it using `#disconnect` when you're done.
lightpack.connect

# If you need to authenticate but haven't done so yet with `.open` or `.new`, 
# you can do so manually after connecting.
lightpack.authenticate("api_key")

# The Lightpack object exposes a lot of interesting information:
lightpack.status      # :on, :off, :device_error or :unknown
lightpack.on?         # true or false
lightpack.api_status  # :idle or :busy

lightpack.profiles    # ["Lightpack", "Other profile"]
lightpack.profile     # "Lightpack"

lightpack.led_count   # 10
lightpack.led_areas   # [{:x=>1920, :y=>1224, :width=>640, :height=>216}, {:x=>2176, :y=>720, ...}, ...] 
lightpack.colors      # [[170, 170, 173], [190, 190, 192], ...] # Red, Green, Blue

lightpack.fps         # 20.04
lightpack.screen_size # [0, 0, 2560, 1440]
lightpack.mode        # :ambilight or :moodlamp

# Of course, you can also _do_ certain things with your Lightpack. 
# All of these return true when successful and raise an error otherwise.
lightpack.turn_on
lightpack.turn_off

lightpack.profile     = "Other profile"
lightpack.mode        = :moodlamp

lightpack.gamma       = 2.5 # 0.1..10
lightpack.brightness  = 93  # 0..100
lightpack.smooth      = 128 # 0..255

lightpack.set_color(0, 255, 0, 0) # index of LED, Red, Green, Blue
lightpack.set_all_colors(0, 255, 0)
lightpack.set_led_areas(0, { x: 1920, y: 1224, width: 640, height: 216 })
lightpack.add_profile("New profile")
lightpack.delete_profile("Other profile")

# Note that all of the action methods above require a lock on the Lightpack.
# This lock is acquired automatically if you haven't done so manually, 
# but if you want to do a number of actions sequentially, acquiring a lock once
# would be more efficient than acquiring and releasing one for every action.

# You can acquire a lock for the duration of a block like this:
lightpack.with_lock do
  lightpack.set_color(0, 255, 0, 0)
  lightpack.set_color(1, 0, 255, 0)
  lightpack.set_color(2, 0, 0, 255)
end

# Alternatively, you can use `#lock` in combination with `#unlock`.
lightpack.lock
lightpack.gamma       = 2.5
lightpack.brightness  = 93
lightpack.smooth      = 128
lightpack.unlock

# If you want to, you can check whether a lock is active:
lightpack.locked?

# When you're done, you can just let the program exit or disconnect explicitly.
lightpack.disconnect
```

## Examples
Check out the [`examples/`](examples) folder for some basic examples.

## License
Copyright (c) 2014 Douwe Maan

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.