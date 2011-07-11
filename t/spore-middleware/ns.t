use strict;
use warnings;
use Test::More;
use Net::HTTP::Spore;
use Test::Exception;

package test::runtime;

use Moose;
extends 'Net::HTTP::Spore::Middleware';

sub call {
    my ( $self, $req) = @_;
    $self->response_cb(
        sub {
            my $res = shift;
            $res->header('X-Test' => 1);
        }
    );
}

package main;

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        $req->new_response( 200, [ 'Content-Type' => 'text/plan' ], 'ok');
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/api.json',
    base_url => 'http://localhost' );

dies_ok { $client->enable('test::runtime') }
"can't load unknown middleware in N::H::Spore namespace";

$client->enable('+test::runtime');
$client->enable('Mock', tests => $mock_server);

my $res = $client->get_info();
ok $res->header('X-Test');

done_testing;
