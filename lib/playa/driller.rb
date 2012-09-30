module Playa
  
  class Driller
    
    # Returns a new query based on the artist
    # and remembers the old query.
    #
    def drill song, query
      remember song, query
      song[:artist].gsub /\/.+$/, ''
    end
    
    # Exits and returns the old query.
    #
    def exit
      query = @query
      @song  = nil
      @query = nil
      query
    end
    
    # Remembers the given query until reset.
    #
    def remember song, query
      @song  ||= song
      @query ||= query
    end
    
  end
  
end