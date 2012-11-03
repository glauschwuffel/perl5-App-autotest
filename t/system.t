use Test::Spec;
use File::Spec;
use File::Basename qw(dirname);

# spec_helper doesn't work for constants
BEGIN { require File::Spec->catfile( dirname(__FILE__), 'helper.pm' ) }

describe 'the autotest' => sub {
    my $autotest = an_autotest();

    it 'should run all test programs upon startup' => sub {
        $autotest->stubs( all_test_programs => SOME_TEST_PROGRAMS );
        $autotest->stubs( test_programs_run => SOME_TEST_PROGRAMS );
        $autotest->harness(a_harness_not_running_the_tests());

        ok $autotest->run_tests_upon_startup;
        is $autotest->number_of_test_programs,
          $autotest->number_of_test_programs_run;
    };



    it 'should run all the tests upon startup and change and creation' => sub {
        $autotest =
          an_autotest_that_just_checks_once_for_changed_or_new_files();
        $autotest->expects('run_tests_upon_startup');
        $autotest->expects('run_tests_upon_change_or_creation');
        ok $autotest->run;
    };


};

runtests unless caller;
