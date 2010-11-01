package Net::HTTP::Spore::Middleware::ParanoidAgent;

use Moose;
extends 'Net::HTTP::Spore::Middleware';

has black_list => ();
has white_list => ();

sub call {
    my ($self, $request) = @_;
}

1;
