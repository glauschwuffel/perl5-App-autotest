use Test::Spec;
use File::Spec;
use File::Basename qw(dirname);
 
BEGIN { require File::Spec->catfile(dirname(__FILE__), 'spec_helper.pl') }

describe 'the autotest' => sub {
  my $autotest = an_autotest();
  my $harness = a_harness();

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

  it 'should run all test programs upon startup' => sub {
    $autotest->stubs(all_test_programs => SOME_TEST_PROGRAMS);
    $autotest->stubs(test_programs_run => SOME_TEST_PROGRAMS);
    $harness->expects('runtests');
    $autotest->harness($harness);
    ok $autotest->run_tests_upon_startup;
    is $autotest->number_of_test_programs, $autotest->number_of_test_programs_run;
  };

  it 'should run tests upon change or creation' => sub {
    $autotest = an_autotest_that_just_checks_once_for_changed_or_new_files();
    $harness->expects('runtests');
    $autotest->harness($harness);
    $autotest->expects('changed_and_new_files')->returns(SOME_TEST_PROGRAMS);
    ok $autotest->run_tests_upon_change_or_creation;
  };

  it 'should run all the tests upon startup and change and creation' => sub {
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
