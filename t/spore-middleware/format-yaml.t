use strict;
use warnings;

use Test::More;
use YAML;

use Net::HTTP::Spore;

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/couchdb.json',
    api_base_url => 'http://localhost:5984' );

my $content = { keys => [qw/1 2 3/] };

$client->enable('Format::YAML');
$client->enable(
    'Test::Response',
    body    => Dump($content),
    headers => [ 'Content-Type' => 'text/x-yaml' ]
);

my $res = $client->get_all_documents( database => 'test_spore' );
is $res->[0],        200;
is_deeply $res->[2], $content;
is $res->header('Content-Type'), 'text/x-yaml';

my $req = $res->request;
is $req->header('Accept'), 'text/x-yaml';

done_testing;
