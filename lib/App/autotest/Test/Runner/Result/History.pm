package App::autotest::Test::Runner::Result::History;

# ABSTRACT: collects test runner results

use strict;
use warnings;

use Moose;
use App::autotest::Test::Runner::Result;
has current_result => ( is => 'rw' );

has last_result => ( is => 'rw' );

sub perpetuate {
  my ( $self, $result ) = @_;

  $self->last_result( $self->current_result ) if $self->current_result;
  $self->current_result($result);
}

sub tests_are_green_again {
  my ( $self ) = @_;

  my $was_bad=$self->last_result->has_failures;
  my $is_good=not $self->current_result->has_failures;

  return $was_bad && $is_good;
}

1;
