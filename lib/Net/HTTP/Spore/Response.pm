package Net::HTTP::Spore::Response;

use strict;
use warnings;

use overload '@{}' => \&finalize;

use HTTP::Headers;

sub new {
    my ( $class, $rc, $headers, $body ) = @_;

    my $self = bless {}, $class;
    $self->status($rc) if defined $rc;
    if (defined $body) {
        $self->body($body);
        $self->raw_body($body);
    }
    $self->headers($headers || []);
    $self;
}

sub code    { shift->status(@_) }
sub content { shift->body(@_) }

sub content_type   { shift->headers->content_type(@_) }
sub content_length { shift->headers->content_length(@_) }

sub status {
    my $self = shift;
    if (@_) {
        $self->{status} = shift;
    }
    else {
        return $self->{status};
    }
}

sub body {
    my $self = shift;
    if (@_) {
        $self->{body} = shift;
    }
    else {
        return $self->{body};
    }
}

sub raw_body {
    my $self = shift;
    if (@_) {
        $self->{raw_body} = shift;
    }else{
        return $self->{raw_body};
    }
}

sub headers {
    my $self = shift;
    if (@_) {
        my $headers = shift;
        if ( ref $headers eq 'ARRAY' ) {
            $headers = HTTP::Headers->new(@$headers);
        }
        elsif ( ref $headers eq 'HASH' ) {
            $headers = HTTP::Headers->new(%$headers);
        }
        $self->{headers} = $headers;
    }
    else {
        return $self->{headers} ||= HTTP::Headers->new();
    }
}

sub request {
    my $self = shift;
    if (@_) {
        $self->{request} = shift;
    }else{
        return $self->{request};
    }
}

sub header {
    my $self = shift;
    $self->headers->header(@_);
}

sub finalize {
    my $self = shift;
    return [
        $self->status,
        +[
            map {
                my $k = $_;
                map { ( $k => $_ ) } $self->headers->header($_);
              } $self->headers->header_field_names
        ],
        $self->body,
    ];
}

1;
