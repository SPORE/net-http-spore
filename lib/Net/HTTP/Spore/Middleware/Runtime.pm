package Net::HTTP::Spore::Middleware::Runtime;

# ABSTRACT: add a new header with runtime

use Moose;
extends 'Net::HTTP::Spore::Middleware';
use Time::HiRes;

sub call {
    my ( $self, $req) = @_;

    my $start_time = [Time::HiRes::gettimeofday];

    $self->response_cb(
        sub {
            my $res = shift;
            my $req_time = sprintf '%.6f',
              Time::HiRes::tv_interval($start_time);
            $res->header('X-Spore-Runtime' => $req_time);
        }
    );
}

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable('Runtime');

    my $result = $client->public_timeline;
    say "request executed in ".$result->header('X-Spore-Runtime');

=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::Runtime is a middleware that add a new header to the response's headers: X-Spore-Runtime. The value of the header is the time the request took to be executed.
