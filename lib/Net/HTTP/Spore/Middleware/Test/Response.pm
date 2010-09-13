package Net::HTTP::Spore::Middleware::Test::Response;

use Moose;
extends 'Net::HTTP::Spore::Middleware';

has status => ( isa => 'Int', is => 'ro', lazy => 1, default => 200 );
has headers => ( isa => 'ArrayRef', is => 'ro', default => sub { [] } );
has callback => (
    isa     => 'CodeRef',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        sub {
            my ( $self, $req ) = @_;
            $req->new_response( $self->status, $self->headers, $self->body, );
        }
    }
);

has body =>
  ( isa => 'HashRef', is => 'ro', lazy => 1, default => sub { { foo => 1 } } );

sub call {
    my ( $self, $req ) = @_;
    $self->callback->($self, $req);
}

1;
