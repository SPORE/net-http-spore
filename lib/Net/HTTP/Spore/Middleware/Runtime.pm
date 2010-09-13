package Net::HTTP::Spore::Middleware::Runtime;

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
