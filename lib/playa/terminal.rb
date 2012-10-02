module Playa
  
  # Note: This is work in progress.
  # It's not yet up to my standards. 
  #
  class Terminal < Clamp::Command
    
    parameter "[pattern]", "a pattern locating your mp3 files", :default => '~/Music/*/*/*/*.mp3'
    option "--[no-]autoplay", :flag, "autoplay after startup or when searching", :default => true
    option "--[no-]debug", :flag, "debug information on startup", :default => false
    option "--[no-]quick-delete", :flag, "quick deletion of whole words", :default => true
    option "--[no-]index", :flag, "forces an indexing run instead of loading", :default => false
    option "--[no-]info", :flag, "manual on startup", :default => true
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
      shut_up :info unless info?
      shut_up :debug unless debug?
      
      extend HighLine::SystemExtensions
      
      player = Playa::Player.new volume
      music = Playa::Music.new pattern
      
      extend Picky::Helpers::Measuring
      duration = timed { music.load }
      Playa.debug.puts "Loaded #{music.size} songs in #{duration.round(1)}s."

      search = Playa::Search.new music
      shortcuts = Playa::Shortcuts.new
      backspace_pattern = quick_delete? ? /(?:\s*\w+?\:?|.)$/ : /.$/
      
      if music.size.zero?
        Playa.info.send :warn, %Q{Sorry, I could not find any songs using your pattern "#{pattern}". Exiting.}
        exit 1
      end
      
      duration = timed { index? ? (search.index; search.dump) : search.load_or_index }
      
      Playa.debug.puts " in #{duration.round(1)}s."
      logger = Playa.info
      logger.puts
      logger.puts "Keys:"
      logger.puts "  enter        -> next song"
      logger.puts "  tab          -> toggle repeat one/all"
      logger.puts "  right arrow  -> only play current artist"
      logger.puts "  left arrow   -> exit from above"
      logger.puts
      logger.puts "Searches:"
      logger.puts "  *            -> all songs"
      logger.puts "  /<genre>     -> search only in genre"
      logger.puts "  \\<song name> -> search only in song titles"
      logger.puts
      logger.puts "Commands:"
      logger.puts "  index?       -> show all the tokens in the index"
      logger.puts "  size?        -> amount of indexed songs"
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
      
      raw_no_echo_mode
      Signal.trap('INT') { restore_mode; exit 0 }
      loop do
        # Ok, I'm tired. How does coding work again? ;)
        #
        new_song_info = current_song_info player, music
        if new_song_info
          song_info = new_song_info
          current_song = [song_info[:title], song_info[:artist] || song_info[:album]].compact.join(" \033[1;37m|\033[0m ")
        end
        
        # history.push query, results
        
        STDOUT.print "\n" if newline?
        STDOUT.print "\r\e[K"
        STDOUT.flush
        
        # Print out the new line.
        #
        STDOUT.print "#{prompt}\x1b[1m#{query}\x1b[0m \033[1;37m#{info}#{aux}\033[0m #{current_song}"[0..119]
        
        # Get char.
        #
        result = nil
        loop do
          # Anybody type anything?
          #
          if IO.select [STDIN], [], [], 0.1
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
            STDOUT.print "#{prompt}#{query} #{info}#{aux} #{current_song}"[0..119]
          end
        end
        
        aux = '' # TODO Rename to once?
        
        case result
        when "\e"
          case STDIN.getc
          when "["
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
                
                # Duplicate code. Refactor.
                #
                results = search.find query
                player.next_up = results
                next
              end
            else
              query << result
            end
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
          plainly { puts search.to_statistics }
          next
        when 'size?'
          plainly { puts "\n"; puts music.size }
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
    
    def plainly
      restore_mode
      yield
      raw_no_echo_mode
    end
    
    def shut_up type
      Playa.send :"#{type}=", Class.new { def method_missing *args, &block; end }.new
    end
    
  end
  
end
