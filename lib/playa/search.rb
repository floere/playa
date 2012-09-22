require 'picky'

module Playa
  
  class Search
    
    attr_reader :index, :music
    
    def initialize music
      @music = music
      @index = Picky::Index.new :playa do
        key_format :to_sym
        indexing splits_text_on: /[\s\.\-]/
        category :title,
                 partial: Picky::Partial::Postfix.new(from: 1)
        category :artist,
                 partial: Picky::Partial::Postfix.new(from: 1)
        category :album,
                 partial: Picky::Partial::Postfix.new(from: 1)
        category :year,
                 partial: Picky::Partial::None.new
        category :genre,
                 partial: Picky::Partial::Postfix.new(from: 1)
      end
    end
    
    # Index the songs.
    #
    def index
      music.each_hash { |id, h| @index.replace_from h }
    end
    
    # Filters according to the given query.
    #
    def find query
      # Search.
      #
      results = songs.search query, 100000 # "all" ids
      
      # Convert results.
      #
      Results.new music, results.ids
    end
    
    # Search interface.
    #
    def songs
      @songs ||= Picky::Search.new @index
    end
    
  end
  
end