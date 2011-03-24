use strict;
use warnings;

use Test::More;
use JSON;

plan tests => 5;

my $conf = {
    'twitter' => {
        spec        => 't/specs/api.json',
        options     => { base_url => 'http://localhost/', },
        middlewares => [ { name => 'Format::JSON' } ],
    }
};

{

    package my::app;
    use Moose;
    with 'Net::HTTP::Spore::Role' => {
        spore_clients => [
            { name => 'twitter', config => 'twitter_config' }
        ]
    };
}

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        $req->new_response(
            200,
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json({status => 'ok'})
        );
    },
};

ok my $app = my::app->new( twitter_config => $conf->{twitter} );
is_deeply $app->twitter_config, $conf->{twitter};

$app->twitter->enable('Mock', tests => $mock_server);
my $res = $app->twitter->get_info();
is $res->[0],        200;
is_deeply $res->[2], {status => 'ok'};
is $res->header('Content-Type'), 'application/json';
