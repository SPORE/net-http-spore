use strict;
use warnings;

use Test::More;
use JSON;

use Net::HTTP::Spore;

my $content = { keys => [qw/1 2 3/] };
my $payload = {user => 'foo'};

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        is( $req->header('Accept'), 'application/json' );
        $req->new_response(
            200,
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($content)
        );
    },
    '/add' => sub {
        my $req = shift;
        is( $req->header('Content-Type'), 'application/json;' );
        is_deeply( JSON::decode_json( $req->body ), $payload );
        $req->new_response(
            200,
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($content)
        );
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost:5984' );

$client->enable('Format::JSON');
$client->enable('Mock', tests => $mock_server);

my $res = $client->get_info();
is $res->[0],        200;
is_deeply $res->[2], $content;
is $res->header('Content-Type'), 'application/json';

my $req = $res->request;
is $req->header('Accept'), 'application/json';

$res = $client->add_user(payload => $payload);
is $res->[0], 200;

done_testing;
