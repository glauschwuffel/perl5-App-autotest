package App::autotest;

use strict;
use warnings;

use Moose;
use File::Find;
use File::Spec;
use Cwd;
use File::ChangeNotify;
use TAP::Harness;

has harness => (is => 'rw',
                isa => 'TAP::Harness',
                default => sub { _default_harness() });

has test_directory => (is => 'rw', isa => 'Str', default => 't');

has watcher => (is => 'rw',
          isa => 'File::ChangeNotify::Watcher',
          default => sub { File::ChangeNotify->instantiate_watcher
            ( directories => [ 't' ],
              filter      => qr/\.t$/
            )});

has after_change_or_new_hook => (is => 'rw',
  isa => 'CodeRef',
  default => sub { sub { 0 }});

sub run {
  my ($self)=@_;

  $self->run_tests_upon_startup;
  $self->run_tests_upon_change_or_creation;

  return 1;
}

sub run_tests_upon_startup {
  my ($self) = @_;

  my @all_test_programs = $self->all_test_programs($self->test_directory);
  # do we have test programs at all?
  return 1 unless @all_test_programs;

  $self->harness->runtests(@all_test_programs);

  return 1;
}

sub run_tests_upon_change_or_creation {
  my ($self) = @_;

  while (1) {
    $self->harness->runtests($self->changed_and_new_files);
    last if $self->after_change_or_new_hook->();
  };
  return 1;
}

{
  my @files;

sub all_test_programs {
  my ($self, $directory)=@_;

  @files=(); # throw away result of last call
  find({wanted => \&_wanted, no_chdir => 1}, $directory);

  return \@files;
};

sub changed_and_new_files {
  my ($self)=@_;

  my @files;
  for my $event ($self->watcher->wait_for_events()) {
    my $type=$event->type();
    my $file_changed=$type eq 'create' || $type eq 'modify';
    push @files, $event->path() if $file_changed;
  }

  return \@files;
};

sub _wanted {
    my $cwd=getcwd();
  my $name=$File::Find::name;
  push @files, File::Spec->catfile($cwd, $name) if $name =~ m{\.t$};
}

}

sub _default_harness {
  my $args = {
           verbosity => 1,
           lib     => [ 'lib', 'blib/lib', 'blib/arch' ],
        };
  return TAP::Harness->new($args);
}

1;
