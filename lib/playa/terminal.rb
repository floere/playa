module Playa
  
  # Note: This is work in progress.
  # It's not yet up to my standards. 
  #
  class Terminal < Clamp::Command
    
    parameter "[pattern]", "a pattern locating your mp3 files", :default => '~/Music/*/*/*/*.mp3'
    option "--[no-]info", :flag, "information on startup", :default => true
    option "--[no-]autoplay", :flag, "autoplay after startup or when searching", :default => true
    option "--[no-]index", :flag, "forces an indexing run instead of loading", :default => false
        
    # Run the terminal interface.
    #
    def execute
      Signal.trap('INT') { exit 0 }
      
      music = Playa::Music.new pattern
      music.load

      search = Playa::Search.new music
      player = Playa::Player.new
      shortcuts = Playa::Shortcuts.new
      
      if music.size.zero?
        puts %Q{Sorry, I could not find any songs using your pattern "#{pattern}". Exiting.}
        exit 1
      end
      
      if info?
        extend Picky::Helpers::Measuring
        print "#{music.size} songs "
        duration = timed { index? ? search.index && search.dump : search.load_or_index }
        puts " in #{duration.round(1)}s."
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
      end
      
      require 'highline/import'
      prompt = '> '
      query = '*'
      info = '(all)'
      gobble = 0
      
      repeat_one = player.repeat_one

      results = Playa::Results.new music, music.songs.keys
      terminal = HighLine.new
      
      player.next_up = results
      player.play if autoplay?
      
      loop do
        current_song = player.current_song
        if current_song
          song_info = music.songs[current_song]
          current_song = [song_info[:title], song_info[:artist] || song_info[:album]].compact.join(' | ') if song_info
        end
        
        result = ask "#{prompt}#{query} #{info} #{current_song}" do |q|
          q.overwrite = true
          q.echo      = false # overwrite works best when echo is false.
          q.character = true  # if this is set to :getc then overwrite does not work
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
          player.play || player.next
          next
        when "\t"
          repeat_one = !repeat_one
          player.toggle_repeat
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
    
  end
  
end