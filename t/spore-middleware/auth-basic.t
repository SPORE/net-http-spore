use strict;
use warnings;

use Test::More;
use MIME::Base64;

use Try::Tiny;
use Net::HTTP::Spore;

my $username = 'franck';
my $password = 's3kr3t';

my $mock_server = {
    '/show' => sub {
        my $req  = shift;
        my $auth = $req->header('Authorization');
        if ($auth) {
            $req->new_response( 200, [ 'Content-Type' => 'text/plain' ], 'ok' );
        }
        else {
            $req->new_response( 403, [ 'Content-Type' => 'text/plain' ],
                'not ok' );
        }
    },
};

my @tests = (
    {
        middlewares => [ [ 'Mock', tests => $mock_server ] ],
        expected => { status => 403, body => 'not ok' }
    },
    {
        middlewares => [
            [ 'Auth::Basic', username => $username, password => $password ],
            [ 'Mock',        tests    => $mock_server ],
        ],
        expected => { status => 200, body => 'ok' }
    },
);

plan tests => 3 * @tests;

foreach my $test (@tests) {
    ok my $client = Net::HTTP::Spore->new_from_spec(
        't/specs/api.json', base_url => 'http://localhost/'
      ),
      'client created';

    foreach ( @{ $test->{middlewares} } ) {
        $client->enable(@$_);
    }

    my $res;

    try { $res = $client->get_info(); } catch { $res = $_ };

    is $res->status, $test->{expected}->{status}, 'valid HTTP status';
    is $res->body, $test->{expected}->{body},   'valid HTTP body';
}
