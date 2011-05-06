use strict;
use warnings;

use Test::More;
use Try::Tiny;
use Net::HTTP::Spore;

my $header_name  = 'X-API-Auth-test';
my $header_value = '12345';

my $mock_server = {
    '/show' => sub {
        my $req  = shift;
        my $auth = $req->header($header_name);
        if ( $auth && $auth eq $header_value ) {
            $req->new_response( 200, [ 'Content-Type' => 'text/plain' ], 'ok' );
        }
        else {
            $req->new_response( 403, [ 'Content-Type' => 'text/plain' ],
                'not ok' );
        }
      }
};

my @tests = (
    {
        middlewares => [ [ 'Mock', tests => $mock_server ] ],
        expected => { status => 403, body => 'not ok' }
    },
    {
        middlewares => [
            [
                'Auth::Header',
                header_name  => $header_name,
                header_value => $header_value
            ],
            [ 'Mock', tests => $mock_server ],
        ],
        expected => { status => 200, body => 'ok' }
    },
    {
        middlewares => [
            [
                'Auth::Header',
                header_name  => $header_name,
                header_value => 'foo'
            ],
            [ 'Mock', tests => $mock_server ],
        ],
        expected => { status => 403, body => 'not ok' }
    },
);

plan tests => 2 * @tests;

foreach my $test (@tests) {
    my $client =
      Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
        base_url => 'http://localhost/' );
    foreach ( @{ $test->{middlewares} } ) {
        $client->enable(@$_);
    }

    my $res;

    try { $res = $client->get_info(); } catch { $res = $_ };

    is $res->status, $test->{expected}->{status}, 'valid HTTP status';
    is $res->body,   $test->{expected}->{body},   'valid HTTP body';
}
