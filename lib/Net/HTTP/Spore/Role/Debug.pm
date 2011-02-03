package Net::HTTP::Spore::Role::Debug;

use Moose::Role;

has trace => (
    is      => 'rw',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $ENV{SPORE_TRACE} ? 1 : 0; }
);

has handle => (
    is => 'rw', isa => 'Object',
);

sub _trace_msg {
    my $self = shift;
    print STDOUT $_[0]."\n" if $self->trace;
}

1;
