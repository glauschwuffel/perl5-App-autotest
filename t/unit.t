use Test::Spec;
use App::autotest;
use TAP::Harness;
use Cwd;
use File::Spec;
use Test::Differences;

use constant TEST_PROGRAMS_DIRECTORY => 't/t';

describe 'the method' => sub {
  describe 'all_test_programs' => sub {
    my $autotest = an_autotest();

    it 'should die if called without directory' => sub {
      trap { $autotest->all_test_programs };
      like $trap->die, qr{missing directory};
    };

    it 'returns the same if called multiple times' => sub {
      my $a=$autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY);
      my $b=$autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY);
      eq_or_diff $a, $b;
    };

    it 'should collect all files ending in .t from a directory' => sub {
      my $cwd=getcwd();
      my @list=map {File::Spec->catfile($cwd, $_) }
         ('t/t/1.t', 't/t/2.t', 't/t/3.t');

      eq_or_diff($autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY),\@list); 
    };
  };

  describe 'changed_and_new_files' => sub {
    my $autotest=an_autotest();

    my $path=TEST_PROGRAMS_DIRECTORY.'/1.t';
    my @expected=($path);

    it 'should find changed files' => sub {
      my $event=stub(type => 'modify', path => $path);
      $autotest->watcher->stubs(wait_for_events => ($event));

      my @got=$autotest->changed_and_new_files;
      eq_or_diff \@got, \@expected;
    };

    it 'should find new files' => sub {
      my $event=stub(type => 'create', path => $path);
      $autotest->watcher->stubs(wait_for_events => ($event));

      my @got=$autotest->changed_and_new_files;
      eq_or_diff \@got, \@expected;
    };
  };

  describe 'run_tests_upon_startup' => sub {
    it 'should succeed even if there are no test programs' => sub {
      my $autotest = an_autotest();
      $autotest->stubs(all_test_programs => []);
      ok($autotest->run_tests_upon_startup);
    };
  };
};

runtests unless caller;

sub an_autotest { return App::autotest->new };

sub an_autotest_that_just_checks_once_for_changed_or_new_files {
  my $autotest=an_autotest();
  $autotest->after_change_or_new_hook(sub { 1 });
  return $autotest;
};

sub a_harness { return TAP::Harness->new };