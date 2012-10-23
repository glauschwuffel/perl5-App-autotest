use Test::Spec;
use App::autotest;
use TAP::Harness;
use Cwd;
use File::Spec;
use Test::Differences;

use constant TEST_PROGRAMS_DIRECTORY => 't/t';
use constant SOME_TEST_PROGRAMS => ();

describe 'the autotest' => sub {
  my $autotest = an_autotest();
  my $harness = a_harness();

  it 'should have a default TAP harness' => sub {
    isa_ok $autotest->harness, 'TAP::Harness';
  };

# The following test fails with:
#   Failed test 'the autotest should run all the tests upon startup' by dying:
#     Can't use an undefined value as an ARRAY reference at .../lib/App/autotest.pm line 45.
#  it 'should run all the tests upon startup' => sub {
#    $harness->expects('runtests');
#    $autotest->harness($harness);
#
#    $autotest->expects('all_test_programs');
#    ok $autotest->run_tests_upon_startup;
#  };  

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

    $autotest->stubs(changed_and_new_files => SOME_TEST_PROGRAMS);

    $autotest->after_change_or_new_hook($hook);
    $autotest->run_tests_upon_change_or_creation;

    is $sum, 4;
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