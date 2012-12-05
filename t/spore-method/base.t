use strict;
use warnings;
use Test::More;
use Test::Exception;
use Net::HTTP::Spore::Meta::Method;

dies_ok {
    Net::HTTP::Spore::Meta::Method->wrap(
        name         => 'test_method',
        package_name => 'test::api',
        body         => sub { 1 },
        path         => '/path',
    );
}
"missing some params";

like $@, qr/Attribute \(method\) is required/;

ok my $method = Net::HTTP::Spore::Meta::Method->wrap(
    name         => 'test_method',
    package_name => 'test::api',
    body         => sub { 1 },
    method       => 'GET',
    path         => '/user/',
  ),
  'method created';

is $method->method, 'GET', 'method is GET';

ok $method = Net::HTTP::Spore::Meta::Method->wrap(
    name         => 'test_method',
    package_name => 'test::api',
    method       => 'GET',
    path         => '/user/',
    params       => { optional => [qw/name id street/] },
    required     => [qw/name id/],
);

ok !$method->has_authentication, 'authentication not set on method';

done_testing;
