use strict;
use Test::More;

use Net::HTTP::Spore::Request;

my $env = {
    REQUEST_METHOD  => 'GET',
    SERVER_NAME     => 'localhost',
    SERVER_PORT     => '80',
    SCRIPT_NAME     => '',
    PATH_INFO       => '/:database/:key',
    REQUEST_URI     => '',
    QUERY_STRING    => '',
    SERVER_PROTOCOL => 'HTTP/1.0',
};

ok my $request = Net::HTTP::Spore::Request->new($env);

is $request->request_uri, '';

$env->{REQUEST_URI} = '/';

is $request->request_uri, '/';

done_testing;
