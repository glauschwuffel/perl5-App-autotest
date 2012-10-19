package App::autotest;

use strict;
use warnings;

use Moose;
use File::Find;
use File::Spec;
use Cwd;

has harness => (is => 'rw', isa => 'TAP::Harness');

sub run_tests_upon_startup {
	my ($self) = @_;

	$self->harness->runtests;
}

sub run_tests_upon_change {
	my ($self) = @_;

	$self->harness->runtests;
}

{
	my @files;

sub all_test_programs {
	my ($self, $directory)=@_;
	find({wanted => \&_wanted, no_chdir => 1}, $directory);

	return \@files;
};

sub _wanted {
    my $cwd=getcwd();
	my $name=$File::Find::name;
	push @files, File::Spec->catfile($cwd, $name) if $name =~ m{\.t$};
}

}

1;
