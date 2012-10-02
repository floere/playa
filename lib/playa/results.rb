module Playa
  
  class Results
    
    attr_reader :music,
                :size
    
    #
    #
    def initialize music, ids = []
      @music = music
      @size = ids.size
      @ids = ids.shuffle.cycle # TODO make more flexible
    end
    
    def empty?
      size.zero?
    end
    
    # Next song.
    #
    def next
      music.find @ids.next
    end
    
  end
  
end