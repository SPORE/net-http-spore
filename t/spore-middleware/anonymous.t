use strict;
use warnings;
use Test::More;

plan tests => 4;

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

my $request_middleware = 0;
my $response_middleware = 0;
$client->enable(
    sub {
        $request_middleware++;
        return sub {
            ok $request_middleware,  'request middleware called';
            ok $response_middleware, 'response middleware called';
        }
    }
);
$client->enable(
    sub {
        ok !$response_middleware, 'response not called yet';
        return sub { $response_middleware++ }
    }
);
# use Devel::SimpleTrace;
$client->enable( 'Mock', tests => $mock_server );
$client->show;
