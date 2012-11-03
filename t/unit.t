use Test::Spec;
use File::Basename qw(dirname);

# spec_helper doesn't work for constants
BEGIN { require File::Spec->catfile( dirname(__FILE__), 'helper.pm' ) }

describe 'the autotest class' => sub {
    my $autotest = an_autotest();
    my $harness  = a_harness();

    it 'should have a default TAP harness' => sub {
        isa_ok $autotest->harness, 'TAP::Harness';
    };

    it 'should have a default directory of test programs' => sub {
        ok $autotest->test_directory;
    };
};

describe 'the method' => sub {
    my $autotest = an_autotest();

    describe 'all_test_programs' => sub {
        it 'should use the accessor function for the test directory' => sub {
            $autotest->expects('test_directory')
              ->returns(TEST_PROGRAMS_DIRECTORY);
            ok $autotest->all_test_programs;
        };

        it 'returns the same if called multiple times' => sub {
            my $a = $autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY);
            my $b = $autotest->all_test_programs(TEST_PROGRAMS_DIRECTORY);
            eq_or_diff $a, $b;
        };

        it 'should collect all files ending in .t from a directory' => sub {
            $autotest->test_directory(TEST_PROGRAMS_DIRECTORY);

            my $cwd = getcwd();
            my @list =
              map { File::Spec->catfile( $cwd, $_ ) }
              ( 't/t/1.t', 't/t/2.t', 't/t/3.t', 't/t/failing.t' );

            eq_or_diff( $autotest->all_test_programs, \@list );
        };
    };

    describe 'changed_and_new_files' => sub {
        my $path     = TEST_PROGRAMS_DIRECTORY . '/1.t';
        my @expected = ($path);

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

    describe 'run_tests_upon_startup' => sub {
        it 'should succeed even if there are no test programs' => sub {
            $autotest->stubs( all_test_programs => [] );
            ok( $autotest->run_tests_upon_startup );
        };
    };

    describe 'test_programs_run' => sub {
        it
'returns reference to empty list if harness_runtests_result is undefined'
          => sub {
            $autotest->stubs( harness_runtests_result => undef );
            cmp_deeply $autotest->test_programs_run, [];
          };
    };

    describe 'number_of_test_programs' => sub {
        it 'should never return a negative number' => sub {
            my $n = $autotest->number_of_test_programs;
            cmp_ok $n, 'ge', 0;
        };
    };

    describe 'number_of_test_programs_run' => sub {
        it 'returns 0 if no test programs ran' => sub {
            my $n = $autotest->number_of_test_programs_run;
            is $n, 0;
        };

        it 'actually returns number of test programs run' => sub {
            $autotest->expects('test_programs_run')
              ->returns(SOME_TEST_PROGRAMS);
            my $n = $autotest->number_of_test_programs_run;
            is $n, scalar @{ (SOME_TEST_PROGRAMS) };
        };
    };

    xdescribe 'run_tests' => sub {
        it 'stores the test results' => sub {
            my $result=a_tap_parser_aggregator();
            my $harness=a_harness();
            $harness->stubs(runtests => $result);
            my $autotest=an_autotest();
            $autotest->harness($harness);
            
            isnt $autotest->harness_runtests_result, $result;
            $autotest->run_tests(SOME_TEST_PROGRAMS);
            is $autotest->harness_runtests_result, $result;
        };
    };
};

runtests unless caller;
