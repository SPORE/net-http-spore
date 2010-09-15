package Net::HTTP::Spore::Middleware::Auth::OAuth;

# ABSTRACT: middleware for OAuth authentication

use Moose;
extends 'Net::HTTP::Spore::Middleware::Auth';

use Net::OAuth;
use MIME::Base64;

has [qw/consumer_key consumer_secret token token_secret/] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub call {
    my ( $self, $req ) = @_;

    return unless $self->should_authenticate($req);

    my $uri = $req->uri;
    my $request = Net::OAuth->request('protected resource')->new(
        version          => '1.0',
        consumer_key     => $self->consumer_key,
        consumer_secret  => $self->consumer_secret,
        token            => $self->token,
        token_secret     => $self->token_secret,
        request_method   => $req->method,
        signature_method => 'HMAC-SHA1',
        timestamp        => time,
        nonce            => MIME::Base64::encode( time . $$ . rand, '' ),
        request_url      => $req->uri,
        # extra_params     => \%post_args,
    );

    $request->sign;
    my $auth = $request->to_authorization_header;
    $req->header( 'Authorization' => $auth );
}

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable(
        'Auth::OAuth',
        consumer_key    => 'xxx',
        consumer_secret => 'yyy',
        token           => '123',
        token_secret    => '456'
    );

=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::Auth::OAuth is a middleware to handle OAuth mechanism. This middleware should be loaded as the last middleware, because it requires all parameters to be setted to calculate the signature.
