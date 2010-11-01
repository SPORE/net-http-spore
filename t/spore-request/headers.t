use strict;
use warnings;

use Test::More tests => 7;
use Net::HTTP::Spore::Request;
use Net::HTTP::Spore;

my $env = { 'HTTP_CONTENT_TYPE' => 'text/html', };

ok my $request = Net::HTTP::Spore::Request->new($env);

isa_ok $request->headers, 'HTTP::Headers';
is $request->header('Content-Type'), 'text/html';
ok $request->header( 'Content-Type' => 'application/json' );
is $request->header('Content-Type'), 'application/json';

my $mock_server = {
    '/file' => sub {
        my $req   = shift;
        my $final = $req->finalize;
        if ( $final->header('Content-Type') eq 'image/png' ) {
            return $req->new_response( 200, [ 'Content-Type' => 'text/html' ],
                'ok' );
        }
        $req->new_response( 500, [ 'Content-Type' => 'text/html' ], 'nok' );
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost', );

$client->enable( 'Mock', tests => $mock_server );

my $res = $client->attach_file( file => 'foo', 'content_type' => 'image/png' );
is $res->[0], 200;

