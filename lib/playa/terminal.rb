module Playa
  
  # Note: This is work in progress.
  # It's not yet up to my standards. 
  #
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
      
      # Dump the index for testing.
      #
      # old_trap = Signal.trap('INT') {}
      # Signal.trap('INT') { search.dump_index; old_trap.call }
      
      extend Picky::Helpers::Measuring
      duration = timed { search.index }
      
      if music.size.zero?
        puts %Q{Sorry, I could not find any songs using your pattern "#{location}". Exiting.}
        exit 1
      end
      
      puts "#{music.size} songs indexed in #{duration.round(1)}s."
      puts search.to_statistics
      puts
      puts "Keys:"
      puts "  enter        -> next song"
      puts "  tab          -> toggle repeat one/all"
      puts "Searches:"
      puts "  *            -> all songs"
      puts "  /<genre>     -> search only in genre"
      puts "  .<song name> -> search only in song titles"
      puts "Commands:"
      puts "  index? size?"
      puts
      
      require 'highline/import'
      prompt = '> '
      query = '*'
      info = '(all)'
      gobble = 0
      
      repeat_one = player.repeat_one

      results = Playa::Results.new music, music.songs.keys
      terminal = HighLine.new
      
      player.play results
      
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
        when "\t"
          repeat_one = !repeat_one
          player.toggle_repeat_one
          info = "(repeat #{repeat_one ? 'this' : 'all'})"
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
  
        # Special queries.
        #
        case query
        when '*'
          player.play Results.new(music, music.songs.keys)
          info = "(all)"
          next
        when 'index?'
          puts search.to_full_statistics
          next
        when 'size?'
          puts music.size
          next
        end
  
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