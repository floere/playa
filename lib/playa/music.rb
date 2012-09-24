# encoding: utf-8
#
module Playa
  
  class Music
    
    attr_reader :pattern, :songs
    
    def initialize pattern = '~/Music/**/*.mp3'
      @pattern = pattern
    end
    
    def find id
      songs[id.to_s] && id.to_s
    end
    
    # TODO Potentially could generate huge strings,
    # making this process larger than necessary.
    #
    def load
      @songs = extract_from id3
    end
    
    # Loads ID3 tags as a id3tool specific string.
    #
    def id3
      `id3tool #{pattern}`.encode! 'UTF-8',
                                   'UTF-8',
                                   :invalid => :replace,
                                   :undef   => :replace
    end
    
    def size
      @songs.size
    end
    
    #
    #
    def each_hash &block
      @songs.each &block
    end
    
    # Returns a hash.
    #
    filename = "Filename:\s*(.+)"
    song     = "(?:\nSong Title:\s*(.+))?"
    artist   = "(?:\nArtist:\s*(.+))?"
    album    = "(?:\nAlbum:\s*(.+))?"
    note     = "(?:\nNote:\s*(?:.+))?"
    track    = "(?:\nTrack:\s*(?:.+))?"
    year     = "(?:\nYear:\s*(.+))?"
    genre    = "(?:\nGenre:\s*(.+))?"
    @@regexp = /#{filename}#{song}#{artist}#{album}#{note}#{track}#{year}#{genre}/
    def extract_from string
      h = {}
      string.scan(@@regexp) do |match|
        id = match[0]
        
        info = { id: id }
        info[:title]  = match[1] ? match[1].strip : File.basename(id)
        info[:artist] = match[2].strip if match[2]
        info[:album]  = match[3].strip if match[3]
        info[:year]   = match[4].strip if match[4]
        info[:genre]  = match[5].strip if match[5]
        
        h[id] = info
      end
      h
    rescue ArgumentError => e
      puts
      puts "I could not handle your mp3 data. Match was: #{match.to_a}."
      puts
      
      raise e
    end
    
  end
  
end