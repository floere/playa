require 'picky'
require 'clamp'
require 'cod'

module Playa
  class << self
    attr_accessor :logger
  end
end

# Default output.
#
Playa.logger = STDOUT

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

