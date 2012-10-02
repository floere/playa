playa
=====

WORK IN PROGRESS!

Command line music player.

Small, does what I needed. Fully searchable. Cool shortcuts. Cmd-tab, tell it something, cmd-tab again.

Needed
------

* OSX 
* ID3 tags on your songs help tremendously

Installation
------------

1. Install Ruby 1.9
2. Install id3tool (on OSX: brew install id3tool)
3. Install sox (only on Linux, http://sox.sourceforge.net/)
4. gem install picky highline clamp cod
5. git clone git://github.com/floere/playa.git
6. cd playa
7. (a) ./bin/playa '~/optional/pattern/\*/\*/*.mp3'
7. (b) ./bin/playa ~/optional/directory/with/mp3s

(Eventually playa will be a gem)

Collaborators
-------------

* [Eloy Durán](http://github.com/alloy) (Bug)
* [Kaspar Schiess](http://github.com/kschiess) (UTF-8 filenames)
* [Oliver Adams](http://github.com/oadams) (Linux version)

TODO
----

* result history
* more interfaces (web etc.)