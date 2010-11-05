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
            authentication => 1,
        }
    },
};

SKIP: {
    skip "require RUN_HTTP_TEST", 3 unless $ENV{RUN_HTTP_TEST};

    my $client = Net::HTTP::Spore->new_from_string( JSON::encode_json($api) );

    $client->enable(
        'Auth::OAuth',
        consumer_key    => 'key',
        consumer_secret => 'secret',
        token           => 'accesskey',
        token_secret    => 'accesssecret',
    );

    ok my $r = $client->echo(method => 'foo', bar => 'baz');
    is $r->status, 200;
    like $r->body, qr/bar=baz&method=foo/;
}
