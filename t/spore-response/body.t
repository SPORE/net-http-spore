use strict;
use warnings;
use Test::More;
use Net::HTTP::Spore::Response;
use URI;

sub r($) {
    my $res = Net::HTTP::Spore::Response->new(200);
    $res->body(@_);
    return $res->finalize->[2];
}

is_deeply r "Hello World", "Hello World";
is_deeply r [ "Hello", "World" ], [ "Hello", "World" ];

{
    my $uri = URI->new("foo");    # stringified object
    is_deeply r $uri, $uri;
}

done_testing;
