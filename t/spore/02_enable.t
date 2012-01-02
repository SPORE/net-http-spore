use strict;
use warnings;
use Test::More;
use Test::Exception;

plan tests => 9;

use IO::All;
use Net::HTTP::Spore;
use Net::HTTP::Spore::Request;

package Net::HTTP::Spore::Middleware::Dummy;
use base qw/Net::HTTP::Spore::Middleware/;

sub call { 1 }

package main;

my $api_spec = 't/specs/api.json';
my %args = ( base_url => 'http://localhost/', );
my $content < io($api_spec);

ok my $client = Net::HTTP::Spore->new_from_spec( $api_spec, %args );

is scalar @{$client->middlewares}, 0, 'no middleware';

dies_ok {
    $client->enable();
} 'middleware name is required';

dies_ok {
    $client->enable('FOOBARBAZAWESOMEMIDDLEWARE');
} 'middleware should be loadable';

dies_ok {
    $client->enable_if('Format::JSON');
} 'enable if require a coderef';

$client->enable('Dummy');
is scalar @{$client->middlewares}, 1, 'middleware dummy added';

$client->reset_middlewares();
is scalar @{$client->middlewares}, 0, 'no middleware loaded';

my $mw_test = sub { (shift)->method eq 'GET'; };

my $request = Net::HTTP::Spore::Request->new({REQUEST_METHOD => 'GET'});

$client->enable_if($mw_test, 'Dummy');

my $res = $client->middlewares->[0]->($request);
is $res, 1, 'condition match';

$request->env->{REQUEST_METHOD} = 'POST';
$res = $client->middlewares->[0]->($request);
ok !$res, 'condition is not matched';
