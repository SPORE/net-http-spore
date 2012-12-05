use strict;
use warnings;
use Test::More;
use Test::Exception;

plan tests => 28;

use JSON;
use IO::All;
use Net::HTTP::Spore;

my $api_spec = 't/specs/api.json';
my $api2_spec = 't/specs/api2.json';

my %args = ( base_url => 'http://localhost/', );

my $github_spec =
  "http://github.com/franckcuny/spore/raw/master/services/github.json";

my $api_ok = {
    base_url => "http://services.org/restapi",
    methods  => { get_info => { method => 'GET', path => '/show' } },
};

my $second_api = {
    base_url => "http://services.org/restapi",
    methods  => { list_users => { method => 'GET', path => '/users' } },
};

my $api_without_path = {
    base_url => "http://services.org/restapi",
    methods  => { get_info => { method => 'GET' } },
};

my $api_without_method = {
    base_url => "http://services.org/restapi",
    methods  => { get_info => { method => 'PET', path => '/show' } },
};

my $api_with_authentication = {
    base_url => "http://services.org/restapi",
    authentication => JSON::true(),
    methods  => { get_info => { method => 'GET', path => '/show' } },
};

dies_ok { Net::HTTP::Spore->new_from_spec };
like $@, qr/specification file is missing/;

dies_ok { Net::HTTP::Spore->new_from_spec( "/foo/bar/baz", ) };
like $@, qr/does not exists/;

dies_ok { Net::HTTP::Spore->new_from_spec( $api_spec ) };
like $@, qr/base_url is missing/;

ok my $client = Net::HTTP::Spore->new_from_spec( $api_spec, %args );
ok $client =
  Net::HTTP::Spore->new_from_string( JSON::encode_json($api_ok), %args );
ok $client->meta->_find_spore_method_by_name(sub{/^get_info$/});

SKIP: {
    skip "require RUN_HTTP_TEST", 2 unless $ENV{RUN_HTTP_TEST};
    ok $client = Net::HTTP::Spore->new_from_spec( $github_spec, %args );
    ok $client->meta->_find_spore_method_by_name(sub{/^user_search$/});
}

dies_ok {
    Net::HTTP::Spore->new_from_string( JSON::encode_json($api_without_path) );
};
like $@, qr/Attribute \(path\) is required/;

dies_ok {
    Net::HTTP::Spore->new_from_string(JSON::encode_json($api_without_method));
};
like $@, qr/Attribute \(method\) does not pass the type constraint/;

ok $client = Net::HTTP::Spore->new_from_string(JSON::encode_json($api_ok));
ok $client->meta->_find_spore_method_by_name(sub{/^get_info$/});

ok $client = Net::HTTP::Spore->new_from_string(JSON::encode_json($api_with_authentication));

dies_ok {
    Net::HTTP::Spore->new_from_strings('/a/b/c', '/a/b/c');
};

for ( {}, { base_url => 'http://localhost/api' } ) {
    ok $client = Net::HTTP::Spore->new_from_strings( JSON::encode_json($api_ok),
        JSON::encode_json($second_api), $_ );
    ok $client->meta->_find_spore_method_by_name( sub { /^get_info$/ } );
    ok $client->meta->_find_spore_method_by_name( sub { /^list_users$/ } );
}

dies_ok {
    $client = Net::HTTP::Spore->new_from_specs($api_spec, $api2_spec);
};
like $@, qr/base_url is missing/;

ok $client =
  Net::HTTP::Spore->new_from_specs( $api_spec, $api2_spec,
    { base_url => 'http://localhost' } );

