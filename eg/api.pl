use strict;
use warnings;
use 5.010;

use Net::HTTP::Spore;

my $username = shift;
my $token = shift;

my $api = Net::HTTP::Spore->new_from_spec(shift);

$api->enable('Net::HTTP::Spore::Middleware::Format::JSON');

$api->enable(
    'Net::HTTP::Spore::Middleware::Auth::Basic',
    username => $username,
    password => $token,
);

my ( $content, $result ) =
  $api->user_information( format => 'json', username => 'franckcuny' );

use YAML::Syck;
warn Dump $content;
