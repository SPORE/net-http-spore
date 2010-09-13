use strict;
use warnings;
use 5.010;

use Net::HTTP::Spore;

my $api = Net::HTTP::Spore->new_from_spec(shift, api_base_url => 'http://localhost:5000');

$api->enable('Net::HTTP::Spore::Middleware::Format::JSON');

$api->enable(
    'Net::HTTP::Spore::Middleware::Auth::Basic',
    username => 'admin',
    password => 's3cr3t'
);

my $content =
  $api->new_user( input => { user => { francktest => { name => 'franck' } } } );

use YAML::Syck;
warn Dump $content;
