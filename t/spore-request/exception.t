use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        die;
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost' );

$client->enable( 'Mock', tests => $mock_server );

my $res = $client->get_info();
is $res->[0], 599;
like $res->[2]->{error}, qr/Died/;

done_testing;
