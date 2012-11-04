use Test::Spec;

use constant A_TEST_WITH_FAILURES => 't/t/failing.t';
use constant A_TEST_WITHOUT_FAILURES => 't/t/succeeding.t';

use App::autotest;

describe 'autotest' => sub {
  it 'tells if things just got better' => sub {
    my $autotest = App::autotest->new;
    $autotest->run_tests(A_TEST_WITH_FAILURES);
    trap { $autotest->run_tests(A_TEST_WITHOUT_FAILURES) };
    is $trap->stdout, "Things just got better.\n";
  };
};

runtests unless caller;
