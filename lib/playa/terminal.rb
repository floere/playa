module Playa
  
  # Note: This is work in progress.
  # It's not yet up to my standards. 
  #
  class Terminal < Clamp::Command
    
    parameter "[pattern]", "a pattern locating your mp3 files", :default => '~/Music/*/*/*/*.mp3'
    option "--[no-]info", :flag, "information on startup", :default => true
    option "--[no-]autoplay", :flag, "autoplay after startup or when searching", :default => true
    option "--[no-]index", :flag, "forces an indexing run instead of loading", :default => false
    
    def current_song_info player, music
      current_song = player.current_song
      music.songs[current_song] if current_song
    end
    
    # Run the terminal interface.
    #
    def execute
      shut_up unless info?
      
      Signal.trap('INT') { exit 0 }
      
      music = Playa::Music.new pattern
      
      extend Picky::Helpers::Measuring
      duration = timed { music.load }
      Playa.logger.puts "Loaded #{music.size} songs in #{duration.round(1)}s."

      search = Playa::Search.new music
      player = Playa::Player.new
      shortcuts = Playa::Shortcuts.new
      
      if music.size.zero?
        Playa.logger.send :warn, %Q{Sorry, I could not find any songs using your pattern "#{pattern}". Exiting.}
        exit 1
      end
      
      duration = timed { index? ? search.index && search.dump : search.load_or_index }
      
      logger = Playa.logger
      logger.puts " in #{duration.round(1)}s."
      logger.puts search.to_statistics
      logger.puts
      logger.puts "Keys:"
      logger.puts "  enter        -> next song"
      logger.puts "  tab          -> toggle repeat one/all"
      logger.puts "Searches:"
      logger.puts "  *            -> all songs"
      logger.puts "  /<genre>     -> search only in genre"
      logger.puts "  .<song name> -> search only in song titles"
      logger.puts "Commands:"
      logger.puts "  index? size?"
      logger.puts
      
      require 'highline/import'
      prompt = '> '
      query = '*'
      info = '(all)'
      song_info = nil
      current_song = nil 
      gobble = 0
      
      repeat_one = player.repeat_one

      results = Playa::Results.new music, music.songs.keys
      terminal = HighLine.new
      
      driller = Driller.new
      
      player.next_up = results
      player.play if autoplay?
      
      loop do
        # Ok, I'm tired. How does coding work again? ;)
        #
        new_song_info = current_song_info player, music
        if new_song_info
          song_info = new_song_info
          current_song = [song_info[:title], song_info[:artist] || song_info[:album]].compact.join(' | ')
        end
        
        result = ask "#{prompt}#{query} #{info} #{current_song}" do |q|
          q.overwrite = true
          q.echo      = false # overwrite works best when echo is false.
          q.character = true  # if this is set to :getc then overwrite does not work
        end
  
        case result
        when "\e" # mark arrows.
          gobble = 2
          next
        when "["
          gobble -= 1
          next
        when "\r"
          player.play || player.next
          next
        when "\t"
          repeat_one = !repeat_one
          player.toggle_repeat
          info = "(repeat #{repeat_one ? 'this' : 'all'})"
          next
        when "\x7F"
          query.chop!
        when "D" # left arrow
          if gobble == 1 # almost finished gobbling
            query = driller.exit || query
            gobble = 0
          end
        when "C"
          if song_info && gobble == 1
            query = driller.drill song_info, query
            gobble = 0
          end
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
          player.next_up = Results.new(music, music.songs.keys)
          player.play if autoplay?
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
          player.next_up = results
          player.play if autoplay?
          "(#{results.size})"
        end
      end
    end
    
    def shut_up
      Playa.logger = Class.new { def method_missing *args, &block; end }.new
    end
    
  end
  
end