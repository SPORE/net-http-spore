use strict;
use warnings;

use Test::More;
use MIME::Base64;

use Net::HTTP::Spore;

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/couchdb.json',
    api_base_url => 'http://localhost:5984' );

my $username = 'franck';
my $password = 's3kr3t';

$client->enable( 'Auth::Basic', username => $username, password => $password );
$client->enable(
    'Test::Response',
    body    => 'result is ok',
    headers => [ 'Content-Type' => 'text/html' ]
);

my $res = $client->get_all_documents( database => 'test_spore' );
is $res->[0], 200;

my $req = $res->request;

is $req->header('Authorization'),
  'Basic ' . encode_base64( $username . ':' . $password, '' );

done_testing;

