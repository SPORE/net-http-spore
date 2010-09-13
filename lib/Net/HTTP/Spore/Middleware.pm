package Net::HTTP::Spore::Middleware;

use strict;
use warnings;

sub new {
    my $class = shift;
    bless {@_}, $class;
}

sub response_cb {
    my ($self, $cb) = @_;

    my $body_filter = sub {
        my $filter = $cb->(@_);
    };
    return $body_filter;
}

sub wrap {
    my ($self, @args) = @_;

    if (!ref $self) {
        $self = $self->new(@args);
    }
    return sub {
        $self->call(@_);
    };
}

1;
