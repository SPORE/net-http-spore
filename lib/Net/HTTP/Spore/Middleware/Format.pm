package Net::HTTP::Spore::Middleware::Format;

# ABSTRACT: base class for formats middlewares

use Moose;
extends 'Net::HTTP::Spore::Middleware';

sub encode       { die "must be implemented" }
sub decode       { die "must be implemented" }
sub accept_type  { die "must be implemented" }
sub content_type { die "must be implemented" }

# sporex.(de)serialization
# spore.format : list supported formats

sub call {
    my ( $self, $req ) = @_;

    return
      if ( exists $req->env->{'sporex.format'}
        && $req->env->{'sporex.format'} == 1 );

    $req->header( $self->accept_type );

    if ( $req->env->{'spore.payload'} ) {
        $req->env->{'spore.payload'} =
          $self->encode( $req->env->{'spore.payload'} );
        $req->header( $self->content_type );
    }

    $req->env->{'sporex.format'} = 1;

    return $self->response_cb(
        sub {
            my $res     = shift;
            my $content = $self->decode( $res->body );
            $res->body($content);
        }
    );
}

1;

