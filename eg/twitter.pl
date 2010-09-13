use strict;
use warnings;
use Net::HTTP::Spore;

use Encode;
use Getopt::Long;

GetOptions(
    'spec=s'            => \my $specification,
    'consumer_key=s'    => \my $consumer_key,
    'consumer_secret=s' => \my $consumer_secret,
    'token=s'           => \my $token,
    'token_secret=s'    => \my $token_secret,
);

my $client = Net::HTTP::Spore->new_from_spec($specification);

$client->enable('Format::JSON');
$client->enable(
    'Auth::OAuth',
    consumer_key    => $consumer_key,
    consumer_secret => $consumer_secret,
    token           => $token,
    token_secret    => $token_secret,
);

my $timeline = $client->public_timeline( format => 'json' );
if ( $timeline->status == 200 ) {
    my $tweets = $timeline->body;
    print ">> Timeline\n";
    foreach my $tweet (@$tweets) {
        print $tweet->{user}->{screen_name} . " says " . encode_utf8($tweet->{text}) . "\n";
    }
    print "\n\n";
}

my $friends_timeline = $client->friends_timeline(format => 'json', include_rts => 1);
if  ($friends_timeline->code == 200) {
    my $tweets = $friends_timeline->body;
    print ">> Friend timeline\n";
    foreach my $tweet (@$tweets) {
        print $tweet->{user}->{screen_name} . " says " . encode_utf8($tweet->{text}) . "\n";
    }
}
