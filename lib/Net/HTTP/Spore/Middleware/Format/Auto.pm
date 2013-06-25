package Net::HTTP::Spore::Middleware::Format::Auto;

use Moose;
use MooseX::Types::Moose qw/HashRef Object/;
extends 'Net::HTTP::Spore::Middleware::Format';

use Try::Tiny;

has serializer => (
    is      => 'rw',
    isa     => HashRef [Object],
    lazy    => 1,
    default => sub { {} },
);

sub call {
    my ( $self, $req ) = @_;

    my $formats = $req->env->{'spore.format'};

    foreach my $format (@$formats) {
        my $cls = "Net::HTTP::Spore::Middleware::Format::" . $format;
        if ( Class::MOP::load($cls) ) {
            my $s = $cls->new;
            $self->serializer->{$format} = $s;
            try {
                if ( $req->env->{'spore.payload'} ) {
                    $req->env->{'spore.payload'} =
                      $s->encode( $req->env->{'spore.payload'} );
                    $req->header( $s->content_type );
                }
                $req->header( $s->accept_type );
                $req->env->{$self->serializer_key} = 1;
            };
            last if $req->env->{$self->serializer_key} == 1;
        }
    }

    return $self->response_cb(
        sub {
            my $res = shift;
            return $res;
        }
    );
}

1;

=head1 DESCRIPTION

B<NOT WORKING>
