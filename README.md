This is the home of the Perl package App::autotest. Welcome!

The project is young and in alpha stage. Currently you need Dist::Zilla
to play with it. To start hacking, install that module:

  cpanm Dist::Zilla
  
Then pull sources from this repository and install the plugins needed for
building the package:

  dzil authordeps | cpanm
  
Then you may build the Perl package App::autotest via

  dzil build

Have fun!
