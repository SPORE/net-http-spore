package Net::HTTP::Spore::Middleware::Auth::Basic;

use Moose;
use MIME::Base64;

extends 'Net::HTTP::Spore::Middleware';

has username => (isa => 'Str', is => 'rw', predicate => 'has_username');
has password => (isa => 'Str', is => 'rw', predicate => 'has_password');

sub call {
    my ( $self, $req ) = @_;

    if ( $self->has_username && $self->has_password ) {
        $req->header(
            'Authorization' => 'Basic '
              . MIME::Base64::encode(
                $self->username . ':' . $self->password, ''
              )
        );
    }
}

1;
