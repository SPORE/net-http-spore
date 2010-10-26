package Net::HTTP::Spore::Role::Debug;

use Moose::Role;

has trace => (
    is      => 'rw',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { $ENV{SPORE_TRACE} ? 1 : 0; }
);

sub _trace_msg { print STDOUT $_[1]."\n" if $_[0]->trace; }

1;
