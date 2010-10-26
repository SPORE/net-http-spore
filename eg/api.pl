use strict;
use warnings;
use 5.010;

use Net::HTTP::Spore;

my $api = Net::HTTP::Spore->new_from_spec(shift);

$api->enable('Net::HTTP::Spore::Middleware::Format::JSON');

my ( $content, $result ) = $api->get_info( format => 'json', username => 'franckcuny' );

say "name => ". $content->{body}->{user}->{name};
