use strict;
use warnings;
use Test::More;
use Net::HTTP::Spore::Response;

sub res {
    my $res = Net::HTTP::Spore::Response->new;
    my %v   = @_;
    while ( my ( $k, $v ) = each %v ) {
        $res->$k($v);
    }
    $res->to_string;
}

is(
    res(
        status => 500,
        body   => 'read timeout',
    ),
    "HTTP status: 500 - read timeout"
);

done_testing;
