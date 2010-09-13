use strict;
use Test::More;

use Net::HTTP::Spore::Request;

my $env = {
    REQUEST_METHOD  => 'GET',
    SERVER_NAME     => 'localhost',
    SERVER_PORT     => '80',
    SCRIPT_NAME     => '',
    PATH_INFO       => '/:database',
    REQUEST_URI     => '',
    QUERY_STRING    => '',
    SERVER_PROTOCOL => 'HTTP/1.0',
    'spore.params'  => [qw/database test_spore key foo rev 123/],
};

ok my $request = Net::HTTP::Spore::Request->new($env);

ok my $http_req = $request->finalize();
isa_ok($http_req, 'HTTP::Request');

is $env->{PATH_INFO}, '/test_spore';
is $env->{QUERY_STRING}, 'key=foo&rev=123';
is $http_req->uri->canonical, 'http://localhost/test_spore?key=foo&rev=123';

done_testing;
