use Test::Spec;
use App::autotest;
use TAP::Harness;
use Cwd;
use File::Spec;
use Test::Differences;

use constant TEST_PROGRAMS_DIRECTORY => 't/t';

describe 'the autotest' => sub {
  my $autotest = an_autotest();
  my $harness = a_harness();

  it 'should have a default TAP harness' => sub {
    isa_ok $autotest->harness, 'TAP::Harness';
  };

  it 'should run all the tests upon startup' => sub {
    my @all_tests=$autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY);
    $harness->expects('runtests')->with(@all_tests);
    $autotest->harness($harness);
    ok $autotest->run_tests_upon_startup;
  };  

  it 'should run tests upon change or creation' => sub {
    $autotest = an_autotest_that_just_checks_once_for_changed_or_new_files();
    $harness->expects('runtests');
    $autotest->harness($harness);
    $autotest->expects('changed_and_new_files');
    ok $autotest->run_tests_upon_change_or_creation;
  };

  it 'should run all the tests upon startup and change' => sub {
    $autotest = an_autotest_that_just_checks_once_for_changed_or_new_files();
    $autotest->expects('run_tests_upon_startup');
    $autotest->expects('run_tests_upon_change_or_creation');
    ok $autotest->run;
  };

  it 'should run as long as after_change_or_new_hook tells it to stop' => sub {
    my @negated_hook_results=(1,1,1,1,0);
    my $sum=0;
    my $hook=sub {
      my $val=shift @negated_hook_results;
      $sum += $val;
      return 1-$val;
    };
    my $times=scalar @negated_hook_results;
    $harness->expects('runtests')->exactly($times);
    $autotest->harness($harness);

    my $test_program=TEST_PROGRAMS_DIRECTORY . 't/t/1.t';
    $autotest->stubs(changed_and_new_files => $test_program);

    $autotest->after_change_or_new_hook($hook);
    $autotest->run_tests_upon_change_or_creation;

    is $sum, 4;
  };

};

describe 'the method' => sub {
  describe 'all_test_programs' => sub {
    my $autotest = an_autotest();

    it 'returns the same if called multiple times' => sub {
      my @a=$autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY);
      my @b=$autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY);
      eq_or_diff \@a, \@b;
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
      $autotest->stubs(all_test_programs => ());
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