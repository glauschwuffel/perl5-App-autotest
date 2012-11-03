package App::autotest::Test::Runner::Result;

# ABSTRACT: represents the result of a test run

use strict;
use warnings;

use Moose;

has harness_result => (
  is      => 'rw',
  isa     => 'TAP::Parser::Aggregator'
);

sub has_failures {
  my ($self)=@_;

  return $self->harness_result->failed > 0;
}

1;
