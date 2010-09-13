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
    'spore.params'  => [qw/database test_spore key foo/],
};

ok my $request = Net::HTTP::Spore::Request->new($env);

is $request->path_info, '/test_spore/foo';

$env->{'spore.params'} = [qw/database test_spore key foo another key/];
is $request->path_info, '/test_spore/foo';

done_testing;
