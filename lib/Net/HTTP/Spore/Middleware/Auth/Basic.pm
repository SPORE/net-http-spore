package Net::HTTP::Spore::Middleware::Auth::Basic;

# ABSTRACT: middleware for Basic authentication

use Moose;
extends 'Net::HTTP::Spore::Middleware::Auth';

use MIME::Base64;

has username => (isa => 'Str', is => 'rw', predicate => 'has_username');
has password => (isa => 'Str', is => 'rw', predicate => 'has_password');

sub call {
    my ( $self, $req ) = @_;

    return unless $self->should_authenticate($req);

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

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('github.json');
    $client->enable('Auth::Basic', username => 'xxx', password => 'yyy');

=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::Auth::Basic is a middleware to handle Basic authentication mechanism.
