use strict;
use warnings;
use Test::More tests => 6;

use Test::Exception;

use JSON;
use Net::HTTP::Spore;

my $api_with_payload = {
    base_url => 'foo',
    methods  => {
        create_user => {
            method           => 'POST',
            path             => '/user',
            required_payload => 1,
        },
        update_user => {
            method           => 'PATCH',
            path             => '/user',
            required_payload => 1,
        },
        list_user => {
            method => 'GET',
            path   => '/user',
        }
    },
};

my $obj =
  Net::HTTP::Spore->new_from_string( JSON::encode_json($api_with_payload),
    base_url => 'http://localhost' );

dies_ok { $obj->create_user(); };
like $@->body->{error}, qr/this method require a payload/;

dies_ok { $obj->list_user( payload => {} ) };
like $@->body->{error}, qr/payload requires a PUT, PATCH or POST method/;

dies_ok { $obj->update_user(); };
like $@->body->{error}, qr/this method require a payload/;
