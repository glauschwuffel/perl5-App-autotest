package App::autotest::Test::Runner::Result::History;

# ABSTRACT: collects test runner results

use strict;
use warnings;

use Moose;
use App::autotest::Test::Runner::Result;

has current_result => ( is => 'rw' );
has last_result => ( is => 'rw' );

=head2 perpetuate ($result)

Stores C<$result> as the new current result.
Shifts the former current result to the last result.

=cut

sub perpetuate {
  my ( $self, $result ) = @_;

  $self->last_result( $self->current_result ) if $self->current_result;
  $self->current_result($result);
}

=head2 things_just_got_better

Things are better if the last run was red and the current run is green.

=cut

sub things_just_got_better {
  my ( $self ) = @_;

  # we can't claim 'better' if we have no last result
  return unless $self->last_result;

  my $was_red=$self->last_result->has_failures;
  my $is_green=not $self->current_result->has_failures;

  return $was_red && $is_green;
}

1;
