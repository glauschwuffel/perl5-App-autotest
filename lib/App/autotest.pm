package App::autotest;

# ABSTRACT: main package for the autotest tool

use strict;
use warnings;

use Moose;
use File::Find;
use File::Spec;
use Cwd;
use File::ChangeNotify;

use App::autotest::Test::Runner;
use App::autotest::Test::Runner::Result::History;

has test_directory => ( is => 'rw', isa => 'Str', default => 't' );

has watcher => (
    is      => 'rw',
    isa     => 'File::ChangeNotify::Watcher',
    default => sub {
        File::ChangeNotify->instantiate_watcher(
            directories => ['t'],
            filter      => qr/\.t$/
        );
    }
);

has after_change_or_new_hook => (
    is      => 'rw',
    isa     => 'CodeRef',
    default => sub {
        sub { 0 }
    }
);

has history => ( is => 'rw',
    default => sub { App::autotest::Test::Runner::Result::History->new } );

has test_runner => ( is => 'rw',
    default => sub { App::autotest::Test::Runner->new });

sub run {
    my ($self) = @_;

    $self->run_tests_upon_startup;
    $self->run_tests_upon_change_or_creation;
}

sub run_tests_upon_startup {
    my ($self) = @_;

    my $all_test_programs = $self->all_test_programs( $self->test_directory );

    $self->run_tests(@$all_test_programs);
}

sub run_tests_upon_change_or_creation {
    my ($self) = @_;

    while (1) {
        $self->run_tests( @{ $self->changed_and_new_files } );

        last if $self->after_change_or_new_hook->();
    }
    return 1;
}

sub changed_and_new_files {
    my ($self) = @_;

    my @files;
    for my $event ( $self->watcher->wait_for_events() ) {
        my $type = $event->type();
        my $file_changed = $type eq 'create' || $type eq 'modify';
        push @files, $event->path() if $file_changed;
    }

    return \@files;
}

{
    my @files;

    sub all_test_programs {
        my ($self) = @_;

        @files = ();    # throw away result of last call
        find( { wanted => \&_wanted, no_chdir => 1 },
            './' . $self->test_directory );

        return \@files;
    }

    sub _wanted {
        my $cwd  = getcwd();
        my $name = $File::Find::name;

        push @files, File::Spec->catfile( $cwd, $name ) if $name =~ m{\.t$};
    }

}

sub run_tests {
    my ($self, @tests)=@_;

    my $result=$self->test_runner->run(@tests);
    $self->history->perpetuate($result);

    if ($self->history->things_just_got_better) {
        $self->print("Things just got better.\n");
    }
}

sub print {
    my ($self, @rest)=@_;
    print @rest;
}

1;
