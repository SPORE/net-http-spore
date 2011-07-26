package Net::HTTP::Spore::Middleware::DoNotTrack;

# ABSTRACT: add a new header to not track

use Moose;
extends 'Net::HTTP::Spore::Middleware';

sub call {
    my ($self, $req) = @_;
    $req->header('x-do-not-track' => 1);
}

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable('DoNotTrack');

=head1 DESCRIPTION

Add a header B<x-do-not-track> to your requests. For more details see L<http://donottrack.us/>.
