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
    $res->finalize;
}

is_deeply(
    res(
        status => 200,
        body   => 'hello',
    ),
    [ 200, +[], 'hello' ]
);

done_testing;
