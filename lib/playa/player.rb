module Playa
  
  #
  #
  class Player
    
    attr_reader :repeat_one,
                :player,
                :channel
    attr_accessor :next_up, :volume
    
    def initialize volume = 0.5
      @channel = Cod.bidir_pipe
      @volume = volume
      @repeat_one = false
      @player = Players.find
      
      at_exit { stop } # clean up
    end
    
    # Start playing (using player specific options).
    #
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
        @current_pid = nil

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
          options = Players.options_for player
          child_pid = spawn player, '-v', volume.to_s, file, *options
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
        true
      end
    end
    
    #
    #
    def toggle_repeat
      # @repeat_one = !@repeat_one
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
