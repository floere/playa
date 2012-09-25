module Playa

  class Player
    
    attr_reader :repeat_one, :player
    
    def initialize
      @repeat_one = false
      select_player
      
      at_exit { stop } # clean up
    end
    
    # A mapping of players and their success error codes.
    #
    @@players = {
      # 'afplay' => 1, # Yep. It's 1.
      'play' => 0
    }
    def select_player
      @player, _ = @@players.find do |(player, success)|
        `#{player} -h > /dev/null 2>&1` rescue nil
        $?.exitstatus == success
      end
      puts "No suitable player found: tried #{@@players.keys.join(', ')}." unless player
    end
    
    # Start playing.
    #
    def play results
      stop
      
      @current_pid = fork do
        $0 = 'playa controller'
        child_pid = nil
        Signal.trap 'QUIT' do
          Process.kill 'KILL', child_pid if child_pid
          exit 0
        end
        Signal.trap 'USR1' do
          Process.kill 'KILL', child_pid if child_pid
        end
        Signal.trap 'USR2' do
          @repeat_one = !@repeat_one
        end
        
        file = results.next || return
        loop do
          child_pid = spawn self.player, '-v', '0.5', file, '> /dev/null 2>&1'
          Process.waitall
          file = results.next unless repeat_one
          break unless file
        end
      end
    end
    
    # 
    #
    def next
      Process.kill 'USR1', @current_pid if @current_pid
    end
    
    # Kill the forked controller.
    #
    def stop
      if @current_pid
        Process.kill 'QUIT', @current_pid
        Process.waitall
        @current_pid = nil
      end
    end
    
    #
    #
    def toggle_repeat_one
      Process.kill 'USR2', @current_pid if @current_pid
    end
    
  end

end