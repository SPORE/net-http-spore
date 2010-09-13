package Net::HTTP::Spore::Middleware::UserAgent;

use Moose;
extends qw/Net::HTTP::Spore::Middleware/;

has useragent => (is => 'ro', isa => 'Str', required => 1);

sub call {
    my ($self, $req) = @_;

    $req->header('User-Agent' => $self->useragent);
}


1;
