use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        ok $req->header('x-do-not-track');
        $req->new_response( 200, [ 'Content-Type' => 'text/plan' ], 'ok');
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost:5984' );

$client->enable('DoNotTrack');
$client->enable('Mock', tests => $mock_server);

my $res = $client->get_info();

done_testing;
