package Net::HTTP::Spore::Middleware::LogDispatch;

# ABSTRACT: Net::HTTP::Spore::Middleware::LogDispatch is a middleware that allow you to use LogDispatch.

use Moose;
extends 'Net::HTTP::Spore::Middleware';

has logger => (is => 'rw', isa => 'Log::Dispatch', required => 1);

sub call {
    my ($self, $req) = @_;

    my $env = $req->env;
    $env->{'sporex.logger'} = sub {
        my $args = shift;
        $args->{level} = 'critical' if $args->{level} eq 'fatal';
        $self->logger->log(%$args);
    };
}

1;

=head1 SYNOPSIS

    my $log = Log::Dispatch->new();
    $log->add(
        Log::Dispatch::File->new(
            name      => 'file1',
            min_level => 'debug',
            filename  => 'logfile'
        )
    );

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable( 'LogDispatch', logger => $log );
