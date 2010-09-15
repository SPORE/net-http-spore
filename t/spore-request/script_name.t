use strict;
use Test::More;

use Net::HTTP::Spore::Request;

my $env = {
    REQUEST_METHOD  => 'GET',
    SERVER_NAME     => 'localhost',
    SERVER_PORT     => '80',
    SCRIPT_NAME     => '',
};

ok my $request = Net::HTTP::Spore::Request->new($env);

is $request->script_name, '';

$env->{SCRIPT_NAME} = '/1/';

is $request->script_name, '/1/';

done_testing;
