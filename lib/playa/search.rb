require 'picky'

module Playa
  
  class Search
    
    attr_reader :music
    
    def initialize music
      Picky.logger = Picky::Loggers::Silent.new
      
      @music = music
      @index = Picky::Index.new directorify(music.pattern) do
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
    def directorify pattern
      pattern.gsub(/\*/, 'x')
             .gsub(/\~/, '_')
             .gsub(/\//, '-')
             .to_sym
    end
    
    # Index the songs.
    #
    def index
      music.each_hash do |id, hash|
        hash = hash.dup
        hash[:title]  = hash[:title].dup # A bit weird, but Picky deletes numbers in titles. TODO change key_format to accept blocks
        hash[:artist] = hash[:artist].dup # A bit weird, but Picky deletes slashes in artists. TODO change key_format to accept blocks
        @index.replace_from hash
      end
      Playa.logger.print 'Indexed songs'
    end
    
    # Note: Totally breaking abstraction here with these print statements.
    #
    def load_or_index
      load rescue (index; dump)
    end
    def load
      @index.load
      Playa.logger.print 'Loaded song index'
    end
    def dump
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
      @songs ||= Picky::Search.new @index do
        searching removes_characters: /[^a-z\s\.\*]/i
      end
    end
    
    #
    #
    def to_statistics
      stats = "Years   "
      stats << @index[:year].exact.weights.keys.sort.join(' ')
      stats << "\nGenres  "
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