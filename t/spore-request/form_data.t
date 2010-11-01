use strict;
use warnings;
use Test::More;

use Net::HTTP::Spore;

my $mock_server = {
    '/email' => sub {
        my $req   = shift;
        my $final = $req->finalize;
        like $final->header('Content-Type'),
          qr/multipart\/form-data; boundary=/;
        $req->new_response( 200, [ 'Content-Type' => 'text/html' ], 'ok' );
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost' );

$client->enable( 'Mock', tests => $mock_server );

my $res = $client->add_email( email => 'foo@bar.com' );
is $res->[0],   200;
like $res->[2], qr/ok/;

done_testing;
