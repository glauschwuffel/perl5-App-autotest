use Test::Spec;

use App::autotest;
use App::autotest::Test::Runner::Result::History;

describe 'an autotest' => sub {
  it 'prints message if tests are green again' => sub {

    my $history=App::autotest::Test::Runner::Result::History->new();
    $history->stubs(tests_are_green_again => 1);

    my $autotest = App::autotest->new(history => $history);

    trap { $autotest->run_tests() };
    is $trap->stdout, "All tests are green again\n";
  };
};

runtests unless caller;
