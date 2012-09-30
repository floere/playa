playa
=====

Work in progress: Awesome command line music player with awesome built-in search and awesomeness!

Name will be changed.

Needed
------

* OSX
* mp3s in an iTunes compatible location in the ~/Music folder (~/Music/\*\*/\*\*/\*\*/*.mp3)
* ID3 tags on your songs help tremendously

Installation
------------

1. Install Ruby 1.9
2. Install id3tool (on OSX: brew install id3tool)
3. Install sox (only on Linux, http://sox.sourceforge.net/)
4. gem install picky highline clamp
5. git clone git://github.com/floere/playa.git
6. cd playa
7. ./bin/playa '~/optional/pattern/\*/\*/*.mp3'

(Eventually playa will be a gem)

Collaborators
-------------

* [Kaspar Schiess](http://github.com/kschiess) (UTF-8 filenames)
* [Oliver Adams](http://github.com/oadams) (Linux version)

TODO
----

* result history
* display song names
* more interfaces (web etc.)