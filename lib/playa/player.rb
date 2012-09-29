module Playa

  class Player
    
    attr_reader :repeat_one,
                :player,
                :channel
    attr_accessor :next_up
    
    def initialize
      @channel = Cod.bidir_pipe # TODO Really ok here?
      @repeat_one = false
      select_player
      
      at_exit { stop } # clean up
    end
    
    # A mapping of players and their success error codes.
    #
    @@players = {
      'afplay' => 1, # Yep. It's 1.
      'play'   => 0
    }
    def select_player
      @player, _ = @@players.find do |(player, success)|
        `#{player} -h > /dev/null 2>&1` rescue nil
        $?.exitstatus == success
      end
      puts "No suitable player found: tried #{@@players.keys.join(', ')}." unless player
    end
    
    # Start playing (using player specific options).
    #
    @@options = {
      'afplay' => [],
      'play' => ['-q']
    }
    def play results = nil
      # This is horribly complicated.
      #
      songs = results || next_up
      songs && self.next_up = nil
      songs || return
      
      stop
      
      @channel = Cod.bidir_pipe
      @current_pid = fork do
        # Some after-forking setup
        #
        $0 = 'playa controller'
        child_pid = nil
        channel.swap!

        Signal.trap 'USR1' do
          message = channel.get
          
          case message
          when :quit
            Process.kill 'KILL', child_pid if child_pid
            exit 0
          when :next
            Process.kill 'KILL', child_pid if child_pid
          when :toggle_repeat
            @repeat_one = !@repeat_one
          end
        end
        
        file = songs.next || return
        channel.put :song => file
        loop do
          options = @@options[self.player]
          child_pid = spawn self.player, *options, '-v', '0.5', file
          Process.waitall
          file = songs.next unless repeat_one
          channel.put :song => file
          break unless file
        end
      end
    end
    
    # 
    #
    def next
      send_child :next
    end
    
    # Kill the forked controller.
    #
    # "There can be only one."
    #
    def stop
      if @current_pid
        send_child :quit
        sleep 0.05
        Process.kill 'QUIT', @current_pid
        Process.waitall
        @current_pid = nil
      end
    end
    
    #
    #
    def toggle_repeat
      send_child :toggle_repeat
    end
    
    #
    #
    def send_child message
      if @current_pid
        channel.put message
        Process.kill 'USR1', @current_pid
      end
    end
    
    #
    #
    def current_song
      ready = Cod.select 0.05, channel.r
      ready && ready.get[:song]
    end
    
  end

end