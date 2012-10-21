This is the home of the Perl package App::autotest. Welcome!

The package provides a program called autotest that runs your test
programs whenever you change them. Using this program, you don't have
to switch between your editor and the shell since your tests are run
automatically when you save them. Think "Continuous Testing".

The project is young and in alpha stage. Currently you need
[Dist::Zilla](http://dzil.org) to play with it. To start hacking,
install that module:

    cpanm Dist::Zilla
  
Then pull sources from this repository and install the plugins needed for
building the package:

    dzil authordeps | cpanm
  
Then you may build the Perl package App::autotest via

    dzil build

Have fun!
