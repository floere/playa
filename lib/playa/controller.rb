module Playa

  class Controller
    
    attr_reader :music
    
    def initialize music, index
      @music, @index = music, index
      @files = []
      @current = nil
    end
    
    # Start playing.
    #
    def play file
      stop
      return unless file
      @current_pid = Process.spawn 'afplay', '-v', '0.5', file
      file
    end
    
    # Filter according to the given query.
    #
    # TODO Run songs from the results of this query.
    #
    def filter query
      # # Expand special search characters.
      # #
      # query = expand query
      
      # Search.
      #
      results = songs.search query, 100000
      
      # Convert results.
      #
      Results.new self, music, results.ids
    end
    
    @@expands = {
      /\// => 'genre:', # select a genre
      /\./ => 'title:'  # choose a specific title
    }
    def expand query
      @@expands.each do |(regexp, replace)|
        query.gsub! regexp, replace
      end
      query
    end
    
    # Index the songs.
    #
    def index
      music.each_hash { |id, h| @index.replace_from h }
    end
    
    def stop
      if @current_pid
        Process.kill 'KILL', @current_pid
        Process.waitall
        @current_pid = nil
      end
    end
    
    def songs
      @songs ||= Picky::Search.new @index
    end
    
  end

end