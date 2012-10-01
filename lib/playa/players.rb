module Playa
  
  # Utility class that finds a useable player (and options).
  #
  class Players
    
    # A mapping of players and their success error codes.
    #
    @@players = {
      'afplay' => 1, # Yep. It's 1.
      'play'   => 0
    }
    def self.find
      player, _ = @@players.find do |(player, success)|
        `#{player} -h > /dev/null 2>&1` rescue nil
        $?.exitstatus == success
      end
      raise "\nNo suitable player found: tried #{@@players.keys.join(', ')}." unless player
      player
    end
    
    @@options = {
      'afplay' => [],
      'play' => ['-q', '-t', 'alsa']
    }
    def self.options_for player
      @@options[player]
    end
    
  end
  
end