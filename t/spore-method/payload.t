use strict;
use warnings;
use Test::More;

use Net::HTTP::Spore;

my $api_with_payload = {
    base_url => 'foo',
    methods  => {
        create_user => {
            method           => 'POST',
            path             => '/user',
            payload_required => 1,
        }
    }
};

