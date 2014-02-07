use strict;
use warnings;
use Test::More;
use Test::Moose;

plan tests => 2;

use JSON;

use Net::HTTP::Spore;

my $content = { keys => [qw/1 2 3/] };

my $mock_server = {
    '/api/show' => sub {
        my $req = shift;
        $req->new_response(
            200,
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($content),
        );
    },
};

my $api = {
    base_url => 'http://services.org/api',
    methods      => {
        'show' => {
            path   => '/show',
            method => 'GET',
        }
    }
};

ok my $client = Net::HTTP::Spore->new_from_string( JSON::encode_json($api) );

$client->enable('Format::Auto');
$client->enable( 'Mock', tests => $mock_server );

has_attribute_ok('Net::HTTP::Spore::Middleware::Format::Auto', 'serializer','has the serializer attribute');

