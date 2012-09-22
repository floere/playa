module Playa

  class Controller
    
    attr_reader :music, :results
    
    def initialize music, index
      @music, @index = music, index
      @files = []
      @results = Results.new self, music
      
      at_exit { stop } # clean up
    end
    
    # Start playing.
    #
    def play
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
    
    # Filter according to the given query.
    #
    def filter query
      # Search.
      #
      results = songs.search query, 100000
      
      # Convert results.
      #
      @results = Results.new self, music, results.ids
    end
    
    # Index the songs.
    #
    def index
      music.each_hash { |id, h| @index.replace_from h }
    end
    
    #
    #
    def stop
      if @current_pid
        Process.kill 'QUIT', @current_pid
        Process.waitall
        @current_pid = nil
      end
    end
    
    # Search interface.
    #
    def songs
      @songs ||= Picky::Search.new @index
    end
    
  end

end