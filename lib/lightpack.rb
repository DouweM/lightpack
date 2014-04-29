require "socket"

class Lightpack
  module Errors
    class NotConnected            < StandardError; end
    class AuthenticationFailed    < StandardError; end

    class AuthenticationRequired  < StandardError; end
    class UnknownCommand          < StandardError; end
    class NotLocked               < StandardError; end
    class Busy                    < StandardError; end
    class Error                   < StandardError; end

    MESSAGES = {
      "authorization required"  => AuthenticationRequired,
      "unknown command"         => UnknownCommand,
      "not locked"              => NotLocked,
      "busy"                    => Busy,
      "error"                   => Error
    }.freeze
  end

  def self.open(*args)
    pack = new(*args)

    begin
      pack.connect
      yield pack
    ensure
      pack.disconnect
    end
  end

  attr_reader   :host, :port
  attr_accessor :api_key

  def initialize(host = "127.0.0.1", port = 3636, api_key = nil)
    @host     = host
    @port     = port
    @api_key  = api_key
  end

  def connected?
    @connected
  end

  def connect
    return false if connected?

    @socket = TCPSocket.new(@host, @port)
    @connected = true

    @socket.gets # Read welcome message

    unless authenticate
      disconnect
      raise Errors::AuthenticationFailed
    end

    true
  rescue
    false
  end

  def disconnect
    return false unless connected?

    unlock

    @connected = false

    @socket.close if @socket && !@socket.closed?
    @socket = nil

    true
  end

  def authenticate(api_key = @api_key)
    return true unless api_key

    command("apikey:#{api_key}") == true
  end

  def locked?
    @locked
  end

  def lock
    return true if locked?

    result = command("lock")
    @locked = result == :success
  end

  def unlock
    return false unless locked?

    result = command("unlock")
    @locked = false

    result == :success
  end

  def with_lock(&block)
    already_locked = locked?

    lock unless already_locked

    yield self
  ensure
    unlock unless already_locked
  end

  # Getters
  def status
    command("getstatus").gsub(" ", "_").to_sym
  end

  def on?
    status == :on
  end

  def api_status
    command("getstatusapi").gsub(" ", "_").to_sym
  end

  def profiles
    command("getprofiles").split(";")
  end

  def profile
    command("getprofile")
  end

  def led_count
    command("getcountleds").to_i
  end

  def led_areas
    command("getleds").split(";").map do |info|
      keys = [:x, :y, :width, :height]
      dimensions = info.split("-", 2)[1].split(",").map(&:to_i)

      Hash[keys.zip(dimensions)]
    end
  end

  def colors
    command("getcolors").split(";").map do |info|
      info.split("-", 2)[1].split(",").map(&:to_i)
    end
  end

  def fps
    command("getfps").to_f
  end

  def screen_size
    command("getscreensize").split(",").map(&:to_i)
  end

  def mode
    command("getmode").to_sym
  end

  # Setters
  def turn_on
    with_lock do
      command("setstatus:on")
    end
  end

  def turn_off
    with_lock do
      command("setstatus:off")
    end
  end

  [:mode, :gamma, :brightness, :smooth, :profile].each do |key|
    define_method(:"#{key}=") do |value|
      with_lock do
        command("set#{key}:#{value}") && value
      end  
    end
  end

  def set_color(n, r, g, b)
    with_lock do
      command("setcolor:#{led_number_at_index(n)}-#{[r, g, b].join(",")};")
    end
  end

  def set_all_colors(r, g, b)
    with_lock do
      colors = [r, g, b].join(",")

      message = "setcolor:"
      led_count.times do |i|
        message << "#{led_number_at_index(i)}-#{colors};"
      end
      command(message)
    end
  end

  def set_led_areas(n, dimensions)
    with_lock do
      dimensions = [:x, :y, :width, :height].map { |key| dimensions[key] }.join(",")
      command("setleds:#{led_number_at_index(n)}-#{dimensions};")
    end
  end

  def add_profile(name)
    with_lock do
      command("newprofile:#{name}")
    end
  end

  def delete_profile(name)
    with_lock do
      command("deleteprofile:#{name}")
    end
  end

  private
    def command(action, type = nil)
      raise Errors::NotConnected unless connected?

      @socket.puts action
      result = @socket.recv(8192).chomp

      if error = Errors::MESSAGES[result]
        raise error 
      end

      if result == "ok"
        true
      elsif result =~ /:/
        result.split(":", 2)[1]
      else
        result.gsub(" ", "_").to_sym
      end
    end

    def led_number_at_index(n)
      n + 1
    end
end

require "lightpack/version"