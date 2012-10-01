module Playa
  
  # A history stack for query results.
  #
  class History
    
    attr_reader :history, :size
    
    #
    #
    def initialize size
      @size    = size
      @history = []
    end
    
    #
    #
    def push query, results
      history.push [query, results]
      history.shift if history.size > size
    end
    
    #
    #
    def pop
      history.pop
    end
    
  end
  
end