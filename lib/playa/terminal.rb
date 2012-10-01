module Playa
  
  # Note: This is work in progress.
  # It's not yet up to my standards. 
  #
  class Terminal < Clamp::Command
    
    parameter "[pattern]", "a pattern locating your mp3 files", :default => '~/Music/*/*/*/*.mp3'
    option "--[no-]autoplay", :flag, "autoplay after startup or when searching", :default => true
    option "--[no-]quick-delete", :flag, "quick deletion of whole words", :default => true
    option "--[no-]index", :flag, "forces an indexing run instead of loading", :default => false
    option "--[no-]info", :flag, "information on startup", :default => true
    option "--[no-]newline", :flag, "newline on song change", :default => false
    option ["-V", "--volume"], "VOLUME", "player volume", :default => 0.5 do |v|
      Float v
    end
    
    def current_song_info player, music
      current_song = player.current_song
      music.songs[current_song] if current_song
    end
    
    # Run the terminal interface.
    #
    def execute
      shut_up unless info?
      
      player = Playa::Player.new volume
      music = Playa::Music.new pattern
      
      extend Picky::Helpers::Measuring
      duration = timed { music.load }
      Playa.logger.puts "Loaded #{music.size} songs in #{duration.round(1)}s."

      search = Playa::Search.new music
      shortcuts = Playa::Shortcuts.new
      backspace_pattern = quick_delete? ? /(?:\s*\w+?\:?|.)$/ : /.$/
      
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
      logger.puts "  right arrow  -> only play current artist"
      logger.puts "  left arrow   -> exit from above"
      logger.puts "Searches:"
      logger.puts "  *            -> all songs"
      logger.puts "  /<genre>     -> search only in genre"
      logger.puts "  \\<song name> -> search only in song titles"
      logger.puts "Commands:"
      logger.puts "  index? size?"
      logger.puts
      
      prompt = '> '
      query = '*'
      info = '(all)'
      aux  = ''
      song_info = nil
      current_song = nil 
      gobble = 0
      
      repeat_one = player.repeat_one

      results = Playa::Results.new music, music.songs.keys
      
      driller = Driller.new
      # history = History.new 5
      
      player.next_up = results
      player.play if autoplay?
      
      extend HighLine::SystemExtensions
      raw_no_echo_mode
      Signal.trap('INT') { restore_mode; exit 0 }
      loop do
        # Ok, I'm tired. How does coding work again? ;)
        #
        new_song_info = current_song_info player, music
        if new_song_info
          song_info = new_song_info
          current_song = [song_info[:title], song_info[:artist] || song_info[:album]].compact.join(' | ')
        end
        
        # history.push query, results
        
        STDOUT.print "\n" if newline?
        STDOUT.print "\r\e[K"
        STDOUT.flush
        
        # Print out the new line.
        #
        STDOUT.print "#{prompt}#{query} #{info}#{aux} #{current_song}"
        
        # Get char.
        #
        result = nil
        loop do
          # Anybody type anything?
          #
          if IO.select [STDIN], [], [], 0.05
            result = STDIN.getbyte.chr
            break
          end
          
          # TODO Doubly duplicated code!
          #
          
          # Any new infos from the player to show?
          #
          new_song_info = current_song_info player, music
          if new_song_info
            song_info = new_song_info
            current_song = [song_info[:title], song_info[:artist] || song_info[:album]].compact.join(' | ')
            
            STDOUT.print "\n" if newline?
            STDOUT.print "\r\e[K"
            STDOUT.flush
            STDOUT.print "#{prompt}#{query} #{info}#{aux} #{current_song}"
          end
        end
        
        aux = ''
        
        case result
        when "\e" # mark arrows.
          if STDIN.getc == "["
            case STDIN.getc
            # when "A" # up arrow
            #   query, results = history.pop
            #   player.next_up = results
            #   player.play if autoplay?
            # when "B" # down arrow
            #   # TODO Forward in history
            when "D" # left arrow
              query = driller.exit || query
            when "C" # right arrow
              if song_info
                query = driller.drill song_info, query
              end
            else
              query << result
            end
          else
            query << result
          end
        when "["
          gobble -= 1
          next
        when "\r"
          player.play || player.next
          next
        when "\t"
          repeat_one = !repeat_one
          player.toggle_repeat
          aux = "(repeat #{repeat_one ? 'this' : 'all'})"
          next
        when "\x7F"
          query.gsub! backspace_pattern, ''
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
        when ""
          info = "(enter query)"
          next
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
    ensure
      restore_mode
    end
    
    def shut_up
      Playa.logger = Class.new { def method_missing *args, &block; end }.new
    end
    
  end
  
end