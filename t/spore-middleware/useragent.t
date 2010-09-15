use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

my $mock_server = {
    '/test_spore/_all_docs' => sub {
        my $req = shift;
        $req->new_response( 200, [ 'Content-Type' => 'text/plain' ], 'ok');
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/couchdb.json',
    api_base_url => 'http://localhost:5984' );

my $ua_str = 'Test::Spore middleware';

$client->enable('UserAgent', useragent => $ua_str);
$client->enable('Mock', tests => $mock_server);

my $res = $client->get_all_documents(database => 'test_spore');
is $res->request->header('User-Agent'), $ua_str;

done_testing;
