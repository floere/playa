module Playa
  
  class Terminal
    
    attr_reader :shortcuts, :location
    
    #
    #
    def initialize
      Signal.trap('INT') { exit 0 }
    end
        
    # Run the terminal interface.
    #
    def run location, shortcuts = Shortcuts.new
      music = Playa::Music.new location
      music.load

      search = Playa::Search.new music
      player = Playa::Player.new
      shortcuts = Playa::Shortcuts.new
      
      extend Picky::Helpers::Measuring
      duration = timed { search.index }
      
      puts "#{music.size} songs indexed in #{duration.round(1)}s."
      puts
      puts "Manual:"
      puts "  enter - next song"
      puts "  type / -> then type genre"
      puts "  type . -> then type specific song name"
      puts
      
      require 'highline/import'
      prompt = '> '
      query = (ARGV.shift || '').dup
      info = ''
      gobble = 0

      results = Playa::Results.new music
      terminal = HighLine.new
      
      loop do
        result = ask "#{prompt}#{query} #{info}" do |q|
            q.overwrite = true
            q.echo      = false  # overwrite works best when echo is false.
            q.character = true   # if this is set to :getc then overwrite does not work
        end
  
        if gobble > 0
          gobble -= 1
          next
        end
        if result == "\e"
          gobble = 2
          next
        end
  
        case result
        when "\r"
          player.next rescue nil
          next
        when "\x7F"
          query.chop!
        else
          query << result
        end
  
        # Expand player shortcuts.
        #
        # (Implement your own if you wish)
        #
        query = shortcuts.expand query
  
        #
        #
        results = search.find query
  
        #
        #
        info = if results.size.zero?
          "(0: ignoring)"
        else
          player.play results
          "(#{results.size})"
        end
      end
    end
    
  end
  
end