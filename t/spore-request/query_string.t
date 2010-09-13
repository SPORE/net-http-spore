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

is $request->query_string, 'key=foo&rev=123';

$env->{PATH_INFO} = '/:database/:key';
is $request->query_string, 'rev=123';

done_testing;
