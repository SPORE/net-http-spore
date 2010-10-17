use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        $req->new_response( 200, [ 'Content-Type' => 'text/plain' ], 'ok');
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost:5984' );

my $ua_str = 'Test::Spore middleware';

$client->enable('UserAgent', useragent => $ua_str);
$client->enable('Mock', tests => $mock_server);

my $res = $client->get_info();
is $res->request->header('User-Agent'), $ua_str;

done_testing;
