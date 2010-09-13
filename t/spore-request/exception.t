use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/couchdb.json',
    api_base_url => 'http://localhost:5984' );

$client->enable( 'Test::Response', callback => sub { die } );

my $res = $client->get_all_documents(database => 'test_spore');
is $res->[0], 599;
like $res->[2]->{error}, qr/Died/;

done_testing;
