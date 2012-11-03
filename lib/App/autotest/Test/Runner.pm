package App::autotest::Test::Runner;

# ABSTRACT: runs tests

use strict;
use warnings;

use Moose;
use TAP::Harness;
use App::autotest::Test::Runner::Result;

has harness => (
  is      => 'rw',
  isa     => 'TAP::Harness',
  default => sub { _default_harness() }
);

has result => (
  is  => 'rw',
  isa => 'App::autotest::Test::Runner::Result'
);

sub run {
  my ( $self, @tests ) = @_;

  my $harness_result = $self->harness->runtests(@tests);
  my $result =
    App::autotest::Test::Runner::Result->new( harness_result => $harness_result );
  $self->result($result);
}

sub had_failures {
  my ($self)=@_;

  return $self->result->has_failures;
}

=head1 INTERNAL METHODS

=cut

sub _default_harness {
    my $args = {
        verbosity => -3,
        lib       => [ 'lib', 'blib/lib', 'blib/arch' ],
    };
    return TAP::Harness->new($args);
}

1;
