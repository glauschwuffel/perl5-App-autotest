use Test::Spec;

use File::Spec;
use File::Basename qw(dirname);

# spec_helper doesn't work for constants
BEGIN {
    require File::Spec->catfile( dirname(__FILE__), File::Spec->updir,
        'helper.pm' );
}

describe 'autotest' => sub {
    it 'indicates all-green after a failing test' => sub {
        my $autotest = an_autotest();

        $autotest->stubs(
            last_run_had_failures => 1,
            this_run_had_failures => 0
        );
        ok $autotest->should_indicate_all_green;
    };

    it "doesn't indicate all-green if last run had no failures, too" => sub {
        my $autotest = an_autotest();

        $autotest->stubs(
            last_run_had_failures => 0,
            this_run_had_failures => 0
        );

        ok not( $autotest->should_indicate_all_green );
    };

    it "doesn't indicate all-green if this run had failures" => sub {
        my $autotest = an_autotest();

        $autotest->stubs( this_run_had_failures => 1 );

        ok not( $autotest->should_indicate_all_green );
    };

    it 'prints the all-green message if it should' => sub {
        my $autotest = an_autotest_that_just_checks_once_for_changed_or_new_files();
        $autotest->harness(a_harness_not_running_the_tests());

        $autotest->expects('changed_and_new_files')
          ->returns(SOME_TEST_PROGRAMS);
        $autotest->stubs( should_indicate_all_green => 1 );
        trap { $autotest->run_tests_upon_change_or_creation };
        is $trap->stdout, 'All tests are green';
    };

    it 'remembers if last run had failures ' => sub {
        my $autotest = an_autotest_that_just_checks_once_for_changed_or_new_files();
        $autotest->harness(a_harness_not_running_the_tests());
        $autotest->expects('changed_and_new_files')
          ->returns(SOME_TEST_PROGRAMS);

        $autotest->last_run_had_failures(1);
        $autotest->stubs( this_run_had_failures => 0 );
        $autotest->run_tests_upon_change_or_creation();
        is $autotest->last_run_had_failures, 0;
    };

    xit 'stores if this run had failures ' => sub {
        my $autotest = an_autotest_that_just_checks_once_for_changed_or_new_files();
        $autotest->harness(a_harness_not_running_the_tests());
        $autotest->expects('changed_and_new_files')
          ->returns(SOME_TEST_PROGRAMS);

        $autotest->this_run_had_failures(1);
        $autotest->stubs(run_tests => 0 );
        $autotest->run_tests_upon_change_or_creation();
        is $autotest->this_run_had_failures, 0;
    };

};

runtests unless caller;
