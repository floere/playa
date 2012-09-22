module Playa

  class Player
    
    def initialize
      at_exit { stop } # clean up
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
        loop do
          break unless file = results.next
          child_pid = spawn 'afplay', '-v', '0.5', file
          Process.waitall
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
    
  end

end