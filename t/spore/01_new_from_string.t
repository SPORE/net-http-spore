use strict;
use warnings;
use Test::More;
use Test::Exception;

plan tests => 14;

use IO::All;
use Net::HTTP::Spore;

my $api_spec = 't/specs/api.json';
my %args = ( base_url => 'http://localhost/', );

my $github_spec =
  "http://github.com/franckcuny/spore/raw/master/services/github.json";

my $content < io($api_spec);

dies_ok { Net::HTTP::Spore->new_from_spec };
like $@, qr/specification file is missing/;

dies_ok { Net::HTTP::Spore->new_from_spec( "/foo/bar/baz", ) };
like $@, qr/does not exists/;

dies_ok { Net::HTTP::Spore->new_from_spec( $api_spec, ) };
like $@, qr/base_url is missing/;

ok my $client = Net::HTTP::Spore->new_from_spec( $api_spec, %args );
ok $client = Net::HTTP::Spore->new_from_string( $content, %args );

SKIP: {
    skip "require RUN_HTTP_TEST", 1 unless $ENV{RUN_HTTP_TEST};
    ok $client = Net::HTTP::Spore->new_from_spec( $github_spec, %args );
}

dies_ok {
    Net::HTTP::Spore->new_from_string(
'{"base_url" : "http://services.org/restapi/","methods" : { "get_info" : { "method" : "GET" } } }'
    );
};
like $@, qr/Attribute \(path\) is required/;

dies_ok {
    Net::HTTP::Spore->new_from_string(
'{"base_url" : "http://services.org/restapi/","methods" : { "get_info" : { "method" : "PET", "path":"/info" } } }'
    );
};
like $@, qr/Attribute \(method\) does not pass the type constraint/;

ok $client = Net::HTTP::Spore->new_from_string(
'{"base_url" : "http://services.org/restapi/","methods" : { "get_info" : { "path" : "/show", "method" : "GET" } } }'
);
