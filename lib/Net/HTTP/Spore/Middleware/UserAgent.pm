package Net::HTTP::Spore::Middleware::UserAgent;

# ABSTRACT: middleware to change the user-agent value

use Moose;
extends qw/Net::HTTP::Spore::Middleware/;

has useragent => (is => 'ro', isa => 'Str', required => 1);

sub call {
    my ($self, $req) = @_;

    $req->header('User-Agent' => $self->useragent);
}

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable('UserAgent', useragent => 'Mozilla/5.0 (X11; Linux x86_64; rv:2.0b4) Gecko/20100818 Firefox/4.0b4');

=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::UserAgent change the default value of the useragent.
