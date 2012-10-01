require 'picky'
require 'clamp'
require 'cod'
require 'highline/system_extensions'

module Playa
  class << self
    attr_accessor :info, :debug
  end
end

# Default output.
#
Playa.info = STDOUT
Playa.debug = STDOUT

#
#
require_relative 'playa/history'
require_relative 'playa/driller'
require_relative 'playa/shortcuts'
require_relative 'playa/music'
require_relative 'playa/search'
require_relative 'playa/results'
require_relative 'playa/players'
require_relative 'playa/player'

#
#
require_relative 'playa/terminal'

