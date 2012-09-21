module Playa
  
  class Results
    
    attr_reader :controller,
                :music,
                :size
    
    def initialize controller, music, ids = []
      @controller = controller
      @music = music
      @size = ids.size
      @ids = ids.shuffle.cycle # for now
      @current = @ids.first.to_s
    end
    
    # Next song.
    #
    def next
      @current = music.find @ids.next
      play
    end
    
    def play
      controller.play @current unless @current.empty?
    end
    
  end
  
end