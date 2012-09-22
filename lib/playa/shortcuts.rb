module Playa
  
  class Shortcuts
    
    # The mapping from shortcut to
    # expanded Picky qualifier.
    #
    # keys can be String/Regexp.
    #
    def expands
      @expands ||= {
        '/' => 'genre:', # select a genre
        '.' => 'title:'  # choose a specific title
      }
    end
    
    # Expands the query,
    # rule after rule, in the order
    # the rules were defined.
    #
    def expand query
      expands.inject(query) do |result, (regexp, replace)|
        result.gsub regexp, replace
      end
    end

    
  end
  
end