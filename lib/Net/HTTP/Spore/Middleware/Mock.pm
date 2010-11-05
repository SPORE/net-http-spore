package Net::HTTP::Spore::Middleware::Mock;

# ABSTRACT: Simple Mocker for Spore middlewares

use Moose;
extends 'Net::HTTP::Spore::Middleware';

has tests => ( isa => 'HashRef', is => 'ro', required => 1 );

sub call {
    my ( $self, $req ) = @_;

    my $finalized_request = $req->finalize;
    foreach my $r ( keys %{ $self->tests } ) {
        next unless $r eq $finalized_request->uri->path;
        my $res = $self->tests->{$r}->($req);
        return $res if defined $res;
    }
}

1;

=head1 SYNOPSIS

    my $mock_server = {
        '/path/i/want/to/match' => sub {
            my $req = shift;
            ...
            $req->new_response(200, ['Content-Type' => 'text/plain'], 'ok');
        }
    };

    my $client = Net::HTTP::Spore->new_from_spec('spec.json');
    $client->enable('Mock', tests => $mock_server);
    my $res = $client->my_rest_method();
    is $res->status, 200;
    is $res->body, 'ok';

=head1 DESCRIPTION
