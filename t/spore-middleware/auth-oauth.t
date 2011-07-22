use strict;
use warnings;
use URI::Escape;
use Test::More;

use Net::HTTP::Spore;
use JSON;

my $api = {
    base_url => "http://localhost",
    name     => "term.ie",
    methods  => {
        get_request_token => {
            path            => "/request_token",
            method          => "GET",
            expected_status => [200],
            authentication  => 1,
        },
        authorize_token => {
            path            => "/authorize_token",
            method          => "GET",
            expected_status => [200],
            required_params => ["oauth_token"],
            authentication  => 1,
        },
        get_access_token => {
            path            => "/access_token",
            method          => "GET",
            expected_status => [200],
            authentication  => 1,
        }
    },
};

my $mock_server = {
    '/request_token' => sub {
        my $req  = shift;
        my $auth = $req->header('Authorization');
        ok $auth;
        like $auth, qr/oauth_consumer_key="key"/;
        $req->new_response(
            200,
            [ 'Content-Type' => 'text/plain' ],
            'oauth_token=requestkey&oauth_token_secret=requestsecret'
        );
    },
    '/access_token' => sub {
        my $req  = shift;
        my $auth = $req->header('Authorization');
        like $auth, qr/oauth_verifier="foo"/;
        $req->new_response( 200, [ 'Content-Type' => 'text/plain' ], 'oauth_token=new_token' );
    },
    '/authorize_token' => sub {
        my $req  = shift;
        my $auth = $req->header('Authorization');
        like $auth, qr/OAuth oauth_consumer_key="key",/;
        $req->new_response( 200, [ 'Content-Type' => 'text/plain' ], 'ok' );
    },
};

my $options = {
    oauth_consumer_key    => 'key',
    oauth_consumer_secret => 'secret',
};

my $client =
  Net::HTTP::Spore->new_from_string( JSON::encode_json($api), trace => 0 );

$client->enable( 'Auth::OAuth', %$options );
$client->enable( 'Mock', tests => $mock_server );

ok my $r = $client->get_request_token();

my $body = $r->body;
while ( $body =~ /([^&=]+)=([^&=]*)&?/g ) {
    my ( $k, $v ) = ( $1, $2 );
    $options->{$k} = uri_unescape($v);
}
is $options->{oauth_token}, 'requestkey';

my $r2 = $client->authorize_token( oauth_token => $options->{oauth_token} );
$options->{oauth_verifier} = "foo";

$client =
  Net::HTTP::Spore->new_from_string( JSON::encode_json($api), trace => 0 );
$client->enable( 'Auth::OAuth', %$options );
$client->enable( 'Mock', tests => $mock_server );

my $r3 = $client->get_access_token();
$body = $r3->body;
while ( $body =~ /([^&=]+)=([^&=]*)&?/g ) {
    my ( $k, $v ) = ( $1, $2 );
    $options->{$k} = uri_unescape($v);
}

is $options->{oauth_token}, 'new_token';

done_testing;
