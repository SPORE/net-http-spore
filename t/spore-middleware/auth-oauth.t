use strict;
use warnings;

use Test::More;

plan tests => 3;

use Net::HTTP::Spore;
use JSON;

my $api = {
    base_url => "http://term.ie/oauth/example",
    name     => "term.ie",
    methods  => {
        echo => {
            path            => "/echo_api.php",
            method          => "GET",
            expected_status => [200],
            authentication  => 1,
        },
        get_request_token => {
            path            => "/request_token.php",
            method          => "GET",
            expected_status => [200],
            authentication  => 1,
        },
        get_access_token => {
            path => "/access_token.php",
            method => "GET",
            expected_status => [200],
            authentication => 1,
        }
    },
};

SKIP: {
    skip "require RUN_HTTP_TEST", 3 unless $ENV{RUN_HTTP_TEST};

    my $client = Net::HTTP::Spore->new_from_string( JSON::encode_json($api), trace => 1 );

    $client->enable(
        'Auth::OAuth',
        oauth_consumer_key    => 'key',
        oauth_consumer_secret => 'secret',
    );

    my $body = $client->get_request_token->body;
    use YAML::Syck; warn $body; ok 1;
    # ok my $r = $client->echo(method => 'foo', bar => 'baz');
    # is $r->status, 200;
    # like $r->body, qr/bar=baz&method=foo/;
}
