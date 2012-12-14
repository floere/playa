module Playa
  
  class Results
    
    attr_reader :music,
                :size
    
    #
    #
    def initialize music, ids = [], options = {}
      @music = music
      @size = ids.size
      @ids = options[:shuffle] ? ids.shuffle.cycle : ids.sort.cycle
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