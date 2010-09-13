package Net::HTTP::Spore::Middleware::Auth::OAuth;

use Moose;
extends 'Net::HTTP::Spore::Middleware';

use Net::OAuth;
use MIME::Base64;

has [qw/consumer_key consumer_secret token token_secret/] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub call {
    my ( $self, $req ) = @_;

    return unless $req->env->{'spore.authentication'} == 1;

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
