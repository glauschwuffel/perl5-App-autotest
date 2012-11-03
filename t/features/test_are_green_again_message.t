use Test::Spec;

use constant A_TEST_WITH_FAILURES => 't/t/failing.t';
use constant A_TEST_WITHOUT_FAILURES => 't/t/succeeding.t';

use App::autotest;

describe 'autotest' => sub {
  it 'prints message if tests are green again' => sub {
    my $autotest = App::autotest->new;
    $autotest->run_tests(A_TEST_WITH_FAILURES);
    trap { $autotest->run_tests(A_TEST_WITHOUT_FAILURES) };
    is $trap->stdout, "All tests are green again\n";
  };
};

runtests unless caller;
