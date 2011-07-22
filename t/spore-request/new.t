use strict;
use Test::More;
use Net::HTTP::Spore::Request;

my $req = Net::HTTP::Spore::Request->new(
    {
        REQUEST_METHOD    => 'GET',
        SERVER_PROTOCOL   => 'HTTP/1.1',
        SERVER_PORT       => 80,
        SERVER_NAME       => 'example.com',
        SCRIPT_NAME       => '/foo',
        REMOTE_ADDR       => '127.0.0.1',
        'spore.url_scheme'    => 'http',
    }
);

isa_ok( $req, 'Net::HTTP::Spore::Request' );

is( $req->method,   'GET',                    'method' );
is( $req->uri,      'http://example.com/foo', 'uri' );
is( $req->port,     80,                       'port' );
is( $req->scheme,   'http',                   'url_scheme' );

done_testing();
