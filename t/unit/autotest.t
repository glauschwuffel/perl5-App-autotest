use Test::Spec;

use App::autotest;
use App::autotest::Test::Runner::Result::History;

use Test::Differences;
use Cwd;
use constant TEST_PROGRAMS_DIRECTORY => 't/t';

use constant A_TEST_PROGRAM       => 't/t/1.t';
use constant ANOTHER_TEST_PROGRAM => 't/t/2.t';
use constant SOME_TEST_PROGRAMS   => [ A_TEST_PROGRAM, ANOTHER_TEST_PROGRAM ];

use constant AN_AFTER_CHANGE_OR_NEW_HOOK_THAT_EXISTS_IMMEDIATELY => sub { 1 };

describe 'an autotest' => sub {
  it 'should have a default directory of test programs' => sub {
    ok an_autotest()->test_directory;
  };

  it 'prints message if tests are green again' => sub {

    my $history = App::autotest::Test::Runner::Result::History->new();
    $history->stubs( tests_are_green_again => 1 );

    my $autotest = App::autotest->new( history => $history );

    trap { $autotest->run_tests() };
    is $trap->stdout, "All tests are green again\n";
  };

  describe 'calling run_tests_upon_startup' => sub {
    it 'calls all_test_programs to know what test programs to run' => sub {
      my $autotest = an_autotest();
      $autotest->expects('all_test_programs');
      $autotest->run_tests_upon_startup;
    };

    it 'calls run_tests to run them' => sub {
      my $autotest = an_autotest();
      $autotest->expects('run_tests');

      $autotest->run_tests_upon_startup;
    };
  };

  describe 'all_test_programs' => sub {
    it 'should use the accessor function for the test directory' => sub {
      my $autotest = an_autotest();
      $autotest->expects('test_directory')->returns(TEST_PROGRAMS_DIRECTORY);
      ok $autotest->all_test_programs();
    };

    it 'returns the same if called multiple times' => sub {
      my $autotest = an_autotest();
      my $a        = $autotest->all_test_programs( $autotest->test_directory );
      my $b        = $autotest->all_test_programs( $autotest->test_directory );
      eq_or_diff $a, $b;
    };

    it 'should collect all files ending in .t from a directory' => sub {
      my $autotest = an_autotest();
      $autotest->test_directory(TEST_PROGRAMS_DIRECTORY);

      my $cwd = getcwd();
      my @list =
        map { File::Spec->catfile( $cwd, $_ ) }
        ( 't/t/1.t', 't/t/2.t', 't/t/3.t',
        't/t/failing.t', 't/t/succeeding.t' );

      eq_or_diff( $autotest->all_test_programs, \@list );
    };
  };

  describe 'changed_and_new_files' => sub {
    my $path     = TEST_PROGRAMS_DIRECTORY . '/1.t';
    my @expected = ($path);

    my $autotest = an_autotest();
    it 'should find changed files' => sub {
      my $event = stub( type => 'modify', path => $path );
      $autotest->watcher->stubs( wait_for_events => ($event) );

      my @got = $autotest->changed_and_new_files;
      eq_or_diff \@got, \@expected;
    };

    it 'should find new files' => sub {
      my $event = stub( type => 'create', path => $path );
      $autotest->watcher->stubs( wait_for_events => ($event) );

      my @got = $autotest->changed_and_new_files;
      eq_or_diff \@got, \@expected;
    };
  };

  # it 'should run tests upon change or creation' => sub {
  #   my $autotest = an_autotest_that_just_checks_once_for_changed_or_new_files();
  #   $autotest->harness( a_harness_not_running_the_tests() );

  #   $autotest->expects('changed_and_new_files')->returns(SOME_TEST_PROGRAMS);
  #   ok $autotest->run_tests_upon_change_or_creation;
  # };
};

sub an_autotest { App::autotest->new(@_) }

sub an_autotest_that_just_checks_once_for_changed_or_new_files {
    my $autotest = an_autotest();
    $autotest->after_change_or_new_hook(
        AN_AFTER_CHANGE_OR_NEW_HOOK_THAT_EXISTS_IMMEDIATELY);
    return $autotest;
}
sub a_harness { return TAP::Harness->new(@_) }

runtests unless caller;
