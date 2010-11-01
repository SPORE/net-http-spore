package Net::HTTP::Spore::Middleware::FileUpload;

use Moose;
extends 'Net::HTTP::Spore::Middleware';

use LWP::MediaTypes qw/read_media_types/;

sub call {
    my ($self, $request) = @_;
}

1;
