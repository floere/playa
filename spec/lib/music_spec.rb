# encoding: utf-8
#
require 'spec_helper'

describe Playa::Music do
  
  let(:music) { described_class.new }
  
  it 'extracts correctly' do
    string = <<-TRACKS
Filename: /Users/hanke/Music/Separate/Wu Tang & Jimi Hendrix/Black Gold/25 What's Happenin'.mp3
Song Title:	What's Happenin'              
Artist:		Wu Tang & Jimi Hendrix        
Album:		Black Gold                    
Note:		http://beatsandblood.blogspo
Track:		25
Year:		2011
Genre:		Other (0xC)

Filename: /Users/hanke/Music/Separate/Wu Tang & Jimi Hendrix/Black Gold/26 The Hood.mp3
Song Title:	The Hood                      
Artist:		Wu Tang & Jimi Hendrix        
Album:		Black Gold                    
Note:		http://beatsandblood.blogspo
Track:		26
Year:		2011
Genre:		Other (0xC)

Filename: /Users/hanke/Music/Separate/Beastie Boys/Beastie Boys Revisited/03 Just A Test (leo nevilo remix).mp3
Song Title:	Just A Test                   
Artist:		Beastie Boys                  
Album:		Beastie Boys Revisited        
Note:		leo nevilo remix            
Track:		3
Year:		2007

Filename: /Users/hanke/Music/Separate/Three Tree Posse/The Quest/13 E Mittwuchnamittag.mp3
TRACKS
    
    music.extract_from(string).should == {
      "/Users/hanke/Music/Separate/Wu Tang & Jimi Hendrix/Black Gold/25 What's Happenin'.mp3" => {
        :id => "/Users/hanke/Music/Separate/Wu Tang & Jimi Hendrix/Black Gold/25 What's Happenin'.mp3",
        :title => "What's Happenin'",
        :artist => "Wu Tang & Jimi Hendrix",
        :album => 'Black Gold',
        :year => '2011',
        :genre => 'Other (0xC)'
      },
      "/Users/hanke/Music/Separate/Wu Tang & Jimi Hendrix/Black Gold/26 The Hood.mp3" => {
        :id => "/Users/hanke/Music/Separate/Wu Tang & Jimi Hendrix/Black Gold/26 The Hood.mp3",
        :title => "The Hood",
        :artist => "Wu Tang & Jimi Hendrix",
        :album => 'Black Gold',
        :year => '2011',
        :genre => 'Other (0xC)'
      },
      "/Users/hanke/Music/Separate/Beastie Boys/Beastie Boys Revisited/03 Just A Test (leo nevilo remix).mp3" => {
        :id => "/Users/hanke/Music/Separate/Beastie Boys/Beastie Boys Revisited/03 Just A Test (leo nevilo remix).mp3",
        :title => "Just A Test",
        :artist => "Beastie Boys",
        :album => 'Beastie Boys Revisited',
        :year => '2007'
      },
      "/Users/hanke/Music/Separate/Three Tree Posse/The Quest/13 E Mittwuchnamittag.mp3" => {
        :id => "/Users/hanke/Music/Separate/Three Tree Posse/The Quest/13 E Mittwuchnamittag.mp3",
        :title => "13 E Mittwuchnamittag",
        :artist => "Three Tree Posse/The Quest"
      }
    }
  end
  
end