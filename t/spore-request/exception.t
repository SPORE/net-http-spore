use strict;
use warnings;

use Try::Tiny;
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
    base_url => 'http://localhost' ), "client created";

$client->enable( 'Mock', tests => $mock_server );

my $res;

try {
    $res = $client->get_info();
}
catch {
    $res = $_;
    like $res, qr/status: 599/, "stringify ok";
    is $res->[0], 599, "status ok (as arrayref)";
    like $res->[2]->{error}, qr/Died/, "body ok (as arrayref)";
};

done_testing;
