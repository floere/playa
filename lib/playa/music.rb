# encoding: utf-8
#
module Playa
  
  class Music
    
    attr_reader :pattern,
                :songs
    
    def initialize pattern = '~/Music/**/*.mp3'
      @songs   = {}
      @pattern = pattern
    end
    
    def find id
      songs[id.to_s] && id.to_s
    end
    
    # TODO Potentially could generate huge strings,
    # making this process larger than necessary.
    #
    def load
      chunked pattern do |subpattern|
        @songs.merge! extract_from(id3 subpattern)
      end
    end
    
    # Loads ID3 tags as a id3tool specific string.
    #
    def id3 pattern
      id3tool(pattern).encode! 'UTF-8',
                               'UTF-8',
                               :invalid => :replace,
                               :undef   => :replace
    end
    
    require 'shellwords'
    def id3tool pattern
      `id3tool #{pattern.gsub(/([^A-Za-z0-9_\-.,:\/@\n\*])/, "\\\\\\1")} 2> /dev/null`
    end
    
    # TODO Chunk on the first - if fail, chunk on the second and so on.
    #
    @@chunk_on = /\*+/
    def chunked pattern
      *head, tail = pattern.partition @@chunk_on
      if tail[/\*/]
        head = File.expand_path head.join
        Dir[head].each do |prefix|
          yield File.join(prefix, tail)
        end
      else
        yield pattern
      end
    end
    
    def size
      @songs.size
    end
    
    # Note: Needed as Picky (currently) destroys the original string when indexing.
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
        puts "ID3 tag was empty. Run id3tool <pattern> to find the problematic ID3 tag." && next if match.empty?
        
        id = match[0]
        
        info = { id: id }
        info[:title]  = match[1] ? match[1].strip : File.basename(id).strip.sub(/\.\w+?$/,'')
        info[:artist] = match[2].strip if match[2]
        info[:album]  = match[3].strip if match[3]
        info[:year]   = match[4].strip if match[4]
        info[:genre]  = match[5].strip if match[5]
        
        h[id] = info
      end
      h
    rescue
      {} # For now, if a pattern results in a problem, return an empty hash.
    end
    
  end
  
end