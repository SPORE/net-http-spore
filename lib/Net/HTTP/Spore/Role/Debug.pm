package Net::HTTP::Spore::Role::Debug;

use IO::File;
use Moose::Role;

has trace => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
        my $self      = shift;
        my $trace_env = $ENV{SPORE_TRACE};
        my @stack = caller; use YAML; warn Dump \@stack;
        my ($fh, $level);
        if ( defined($trace_env) && ( $trace_env =~ /(\d)=(.+)$/ ) ) {
            $level = $1;
            $fh = IO::File->new( $2, 'w' )
              or die("Cannot open trace file $1");
        }
        else {
            $level = $trace_env;
            $fh = IO::File->new('>&STDERR')
              or die('Duplication of STDERR for debug output failed (perhaps your STDERR is closed?)');
        }
        $fh->autoflush();
        $self->_trace_fh($fh);
        return $level;
    }
);

has _trace_fh => (
    is      => 'rw',
    isa     => 'GLOB',
);

sub _trace_msg {
    my $self     = shift;
    my $template = shift;
    return unless $self->trace;
    my $fh = $self->_trace_fh();
    print $fh (sprintf( $template, @_ )."\n");
}

sub _trace_verbose {
    my $self = shift;
    return unless $self->trace && $self->trace > 1;
    $self->_trace_msg(@_);
}

1;
