use strict;
use warnings;

use Test::More;

plan tests => 2;

use Net::HTTP::Spore;

SKIP: {
    skip "require RUN_HTTP_TEST", 2 unless $ENV{RUN_HTTP_TEST};
    my $client = Net::HTTP::Spore->new_from_string(
        '{
    "base_url" : "http://fperrad.googlepages.com",
      "name"   : "googlepages",
      "methods"
      : { "get_home"
        : { "path" : "/home", "method" : "GET", "expected_status" : [200] } }
    }');

    $client->enable('Redirection');

    my $r = $client->get_home();
    is $r->status, 200;
    is $r->request->uri,
      'http://sites.google.com/site/fperrad/home';
}
