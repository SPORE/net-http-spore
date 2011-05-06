package Net::HTTP::Spore::Middleware::Auth::Header;

# ABSTRACT: middleware for authentication with specific header

use Moose;
extends 'Net::HTTP::Spore::Middleware::Auth::Auth';

has header_name => (isa => 'Str', is => 'rw', required => 1);
has header_value => (isa => 'Str', is => 'rw', required => 1);

sub call {
    my ($self, $req) = @_;

    return unless $self->should_authenticate($req);

    $req->header($self->header_name => $self->header_value);
}

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('api.json');
    $client->enable(
        'Auth::Header',
        header_name  => 'X-API-Auth',
        header_value => '12345'
    );

=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::Auth::Header is a middleware to handle authentication mechanism that requires a specific header name.
