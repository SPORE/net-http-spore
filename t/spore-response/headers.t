use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore::Response;

my $status = 200;
my $body = '{"foo":1}';
my $ct   = 'application/json';
my $cl   = length($body);

my $response =
  Net::HTTP::Spore::Response->new( $status,
    [ 'Content-Type', $ct, 'Content-Length', length($body) ], $body );

is $response->content_type,   $ct;
is $response->content_length, $cl;
is $response->status, 200;

done_testing;
