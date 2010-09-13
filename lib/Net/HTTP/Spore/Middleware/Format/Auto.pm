package Net::HTTP::Spore::Middleware::Format::Auto;

use Moose;
extends 'Net::HTTP::Spore::Middleware::Format';

sub call {
    my ( $self, $req ) = @_;

    $req->env->{'sporex.format'} = 1;

    return $self->response_cb( sub {
        my $res = shift;
        return $res;
    });
}

1;
