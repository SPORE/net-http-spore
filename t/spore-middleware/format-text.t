use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

my $content = 'response';
my $payload = 'request payload';

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        is( $req->header('Accept'), 'text/plain' );
        $req->new_response(
            200,
            [ 'Content-Type' => 'text/plain' ],
            $content
        );
    },
    '/add' => sub {
        my $req = shift;
        is( $req->header('Content-Type'), 'text/plain' );
        is( $req->body , $payload );
        $req->new_response(
            200,
            [ 'Content-Type' => 'text/plain' ],
            $content
        );
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost:5984' );

$client->enable('Format::Text');
$client->enable('Mock', tests => $mock_server);

my $res = $client->get_info();
is $res->[0],        200;
is $res->[2], $content;
is $res->header('Content-Type'), 'text/plain';

my $req = $res->request;
is $req->header('Accept'), 'text/plain';

$res = $client->add_user(payload => $payload);
is $res->[0], 200;

done_testing;
