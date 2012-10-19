use Test::Spec;
use App::autotest;
use TAP::Harness;
use Cwd;
use File::Spec;

describe 'the program' => sub {
  my $autotest = an_autotest();
  my $harness = a_harness();

  it 'should run all the tests upon startup' => sub {
    $harness->expects('runtests');
    $autotest->harness($harness);
    $autotest->run_tests_upon_startup();
  };  

  it 'should run all the tests upon change' => sub {
    $harness->expects('runtests');
    $autotest->harness($harness);
    $autotest->run_tests_upon_change();
  };

  it 'should collect all files ending in .t from a directory' => sub {
    my $cwd=getcwd();
    my @list=map {File::Spec->catfile($cwd, $_) }
       ('t/t/1.t', 't/t/2.t', 't/t/3.t');

    is_deeply($autotest->all_test_programs('t/t'),\@list); 
  };
};

runtests unless caller;

sub an_autotest { return App::autotest->new };

sub a_harness { return TAP::Harness->new };