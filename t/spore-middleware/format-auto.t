use strict;
use warnings;
use Test::More;

plan tests => 1;

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
    api_base_url => 'http://services.org/api',
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

