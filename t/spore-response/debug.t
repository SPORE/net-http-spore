use strict;
use warnings;
use Test::More;
use Net::HTTP::Spore;
use File::Temp;

my $mock_server = {
    '/show' => sub {
        my $req = shift;
        $req->new_response( 200, [ 'Content-Type' => 'text/plan' ], 'ok');
    }
};

my $fh = File::Temp->new();
my $filename = $fh->filename;

ok my $client = Net::HTTP::Spore->new_from_spec(
    't/specs/api.json',
    base_url => 'http://localhost',
    trace    => "1=$filename"
  ),
  "client created";

$client->enable( 'Mock', tests => $mock_server );

my $res = $client->get_info();

ok -f $filename;

close $fh;

open $fh, '<', $filename;
my $out = <$fh>;
close $fh;

like $out, qr/enabling middleware Net::HTTP::Spore::Middleware::Mock/;

done_testing;
