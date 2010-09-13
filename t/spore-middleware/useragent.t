use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/couchdb.json',
    api_base_url => 'http://localhost:5984' );

my $ua_str = 'Test::Spore middleware';

$client->enable('UserAgent', useragent => $ua_str);
$client->enable('Test::Response');

my $res = $client->get_all_documents(database => 'test_spore');
is $res->request->header('User-Agent'), $ua_str;

done_testing;
