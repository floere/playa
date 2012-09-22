module Playa
  
  class Results
    
    attr_reader :controller,
                :music,
                :size,
                :current
    
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
      music.find @ids.next
    end
    
  end
  
end