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

sub raw($) {
    my $res = Net::HTTP::Spore::Response->new(200);
    $res->raw_body(@_);
    return $res->raw_body;
}

sub content($) {
    my $res = Net::HTTP::Spore::Response->new(200);
    $res->body(@_);
    return $res->content;
}

is_deeply r "Hello World", "Hello World";
is_deeply r [ "Hello", "World" ], [ "Hello", "World" ];

is_deeply raw "Hello World", "Hello World";
is_deeply raw [ "Hello", "World" ], [ "Hello", "World" ];

is_deeply content "Hello World", "Hello World";
is_deeply content [ "Hello", "World" ], [ "Hello", "World" ];

done_testing;
