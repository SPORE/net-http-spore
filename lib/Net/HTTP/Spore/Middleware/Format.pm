package Net::HTTP::Spore::Middleware::Format;

# ABSTRACT: base class for formats middlewares

use Moose;
extends 'Net::HTTP::Spore::Middleware';

has serializer_key =>
  ( is => 'ro', isa => 'Str', lazy => 1, default => 'sporex.serialization' );
has deserializer_key =>
  ( is => 'ro', isa => 'Str', lazy => 1, default => 'sporex.deserialization' );

sub encode       { die "must be implemented" }
sub decode       { die "must be implemented" }
sub accept_type  { die "must be implemented" }
sub content_type { die "must be implemented" }

sub should_serialize {
    my $self = shift;
    $self->_check_serializer( shift, $self->serializer_key );
}

sub should_deserialize {
    my $self = shift;
    $self->_check_serializer( shift, $self->deserializer_key );
}

sub _check_serializer {
    my ( $self, $env, $key ) = @_;
    if ( exists $env->{$key} && $env->{$key} == 1 ) {
        return 0;
    }
    else {
        return 1;
    }
}

sub call {
    my ( $self, $req ) = @_;

    return unless $self->should_serialize( $req->env );

    $req->header( $self->accept_type );

    if ( $req->env->{'spore.payload'} ) {
        $req->env->{'spore.payload'} =
          $self->encode( $req->env->{'spore.payload'} );
        $req->header( $self->content_type );
    }

    $req->env->{ $self->serializer_key } = 1;

    return $self->response_cb(
        sub {
            my $res = shift;
            if ( $res->body ) {
                return if $res->code >= 500;
                return unless $self->should_deserialize( $res->env );
                my $content = $self->decode( $res->body );
                $res->body($content);
                $res->env->{ $self->deserializer_key } = 1;
            }
        }
    );
}

1;

__END__

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable('Format::JSON');

    my $res = $client->public_timeline();
    # $res->body contains an hashref build from the JSON returned by the API

=head1 DESCRPITION

This middleware is a base class for others format's middleware. Thoses middlewares must set the appropriate B<Content-Type> and B<Accept> header to the request.

If the environment contains a B<payload> (under the name 'spore.payload'), it should also serialize this data to the appropriate format (eg: if payload contains an hashref, and the format is json, the hashref B<MUST> be serialized to JSON).

=head1 METHODS

=over 4

=item serializer_key

name of the extension serializer should check to be sure to not encode a payload already encoded, or set the headers that have already been defined

=item deserializer_key

as previously, but for the response instead of the request

=item encode

this method B<MUST> be implemented in class extending this one. This method B<MUST> return an encoded string from the argument passed.

=item decode

this method B<MUST> be implemented in class extending this one. This method B<MUST> return a reference from the undecoded string passed as argument.

=item accept_type

this method B<MUST> be implemented in class extending this one. This method B<MUST> return a string that will be used as the B<Accept> HTTP header.

=item content_type

this method B<MUST> be implemented in class extending this one. This method B<MUST> return a string that will be used as the B<Content-Type> HTTP header.

=item should_serialize

this method returns 1 if serialization have not already been done

=item should_deserialize

this method returns 1 if deserialization have not already been done

=item call

=back
