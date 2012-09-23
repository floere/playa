require 'picky'

module Playa
  
  class Search
    
    attr_reader :music
    
    def initialize music
      @music = music
      @index = Picky::Index.new :music do
        key_format :to_sym
        category :title,
                 partial: Picky::Partial::Postfix.new(from: 1),
                 indexing: {
                   removes_characters: /[^a-z\s\.]/i,
                   splits_text_on: /[\s\.]/
                 }
        category :artist,
                 partial: Picky::Partial::Postfix.new(from: 1),
                 indexing: {
                   removes_characters: /[^a-z\s\.]/i,
                   splits_text_on: /[\s\.]/
                 }
        category :album,
                 partial: Picky::Partial::Postfix.new(from: 1),
                 indexing: {
                   removes_characters: /[^a-z\s\.]/i,
                   splits_text_on: /[\s\.]/
                 }
        category :year,
                 partial: Picky::Partial::None.new,
                 indexing: {
                   removes_characters: /[^0-9\/]/,
                   splits_text_on: /[\s\/]/
                 }
        category :genre,
                 partial: Picky::Partial::Postfix.new(from: 1),
                 indexing: {
                   removes_characters: /\(.+\)/i
                 }
      end
    end
    
    # Index the songs.
    #
    def index
      music.each_hash { |id, h| @index.replace_from h }
    end
    
    #
    #
    def dump_index
      @index.dump
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
    
    #
    #
    def to_statistics
      stats = "Statistics (years and genres)"
      stats << "\n  "
      stats << @index[:year].exact.weights.keys.sort.join(' ')
      stats << "\n  "
      stats << @index[:genre].exact.weights.keys.sort.join(' ')
      stats
    end
    
    #
    #
    def to_full_statistics
      stats = to_statistics
      stats << "\nSongs\n  "
      stats << @index[:title].exact.weights.keys.sort.join(' ')
      stats << "\nArtists\n  "
      stats << @index[:artist].exact.weights.keys.sort.join(' ')
      stats << "\nAlbums\n  "
      stats << @index[:album].exact.weights.keys.sort.join(' ')
    end
    
  end
  
end