package Net::HTTP::Spore::Request;

# ABSTRACT: Net::HTTP::Spore::Request - Portable HTTP request object from SPORE env hash

use strict;
use warnings;

use Carp ();
use URI;
use HTTP::Headers;
use HTTP::Request;
use URI::Escape;
use Hash::MultiValue;

use Net::HTTP::Spore::Response;

sub new {
    my ( $class, $env ) = @_;

    Carp::croak('$env is required') unless defined $env && ref($env) eq 'HASH';
    bless { env => $env }, $class;
}

sub env         { $_[0]->{env} }
sub method      { $_[0]->{env}->{REQUEST_METHOD} }
sub port        { $_[0]->{env}->{SERVER_PORT} }
sub script_name { $_[0]->{env}->{SCRIPT_NAME} }
sub path        { $_[0]->path_info }
sub request_uri { $_[0]->{env}->{REQUEST_URI} }
sub scheme      { $_[0]->{env}->{'spore.scheme'} }
sub logger      { $_[0]->{env}->{'sporex.logger'} }
sub secure      { $_[0]->scheme eq 'https' }
sub content     { $_[0]->{env}->{'spore.payload'} }
sub body        { $_[0]->{env}->{'spore.payload'} }
sub input       { $_[0]->{env}->{'spore.payload'} }

sub path_info {
    my $self = shift;
    my ($path) = $self->_path;
    $path;
}

sub _path {
    my $self = shift;

    my $query_string;
    my $path = $self->env->{PATH_INFO};
    my @params = @{ $self->env->{'spore.params'} || [] };

    my $j = 0;
    for (my $i = 0; $i < scalar @params; $i++) {
        my $key = $params[$i];
        my $value = $params[++$i];
        if (!$value) {
            $query_string .= $key;
            last;
        }
        unless ( $path && $path =~ s/\:$key/$value/ ) {
            $query_string .= $key . '=' . $value;
            $query_string .= '&' if $query_string && scalar @params;
        }
    }

    $query_string =~ s/&$// if $query_string;
    return ( $path, $query_string );
}

sub query_string {
    my $self = shift;
    my ( undef, $query_string ) = $self->_path;
    $query_string;
}

sub headers {
    my $self = shift;
    if ( !defined $self->{headers} ) {
        my $env = $self->env;
        $self->{headers} = HTTP::Headers->new(
            map {
                ( my $field = $_ ) =~ s/^HTTPS?_//;
                ( $field => $env->{$_} );
              } grep { /^(?:HTTP|CONTENT)/i } keys %$env
        );
    }
    $self->{headers};
}

sub header {shift->headers->header(@_)}

sub uri {
    my $self = shift;

    my $path_info    = shift;
    my $query_string = shift;

    if ( !defined $path_info || !defined $query_string ) {
        my @path_info = $self->_path;
        $path_info    = $path_info[0] if !$path_info;
        $query_string = $path_info[1] if !$query_string;
    }

    my $base = $self->_uri_base;

    my $path_escape_class = '^A-Za-z0-9\-\._~/';

    my $path = URI::Escape::uri_escape($path_info || '', $path_escape_class);

    if (defined $query_string) {
        $path .= '?' . $query_string;
    }

    $base =~ s!/$!! if $path =~ m!^/!;
    return URI->new( $base . $path )->canonical;
}

# retourner les query parameters ? vu qu'on a pas encore peuple l'url, on gere comment ?
sub query_parameters {
    my $self = shift;
}

sub base {
    my $self = shift;
    URI->new( $self->_uri_base )->canonical;
}

sub _uri_base {
    my $self = shift;
    my $env  = $self->env;

    my $uri =
      ( $env->{'spore.url_scheme'} || "http" ) . "://"
      . (
        $env->{HTTP_HOST}
          || (( $env->{SERVER_NAME} || "" ) . ":"
            . ( $env->{SERVER_PORT} || 80 ) )
      ) . ( $env->{SCRIPT_NAME} || '/' );
    return $uri;
}

sub new_response {
    my $self = shift;
    my $res = Net::HTTP::Spore::Response->new(@_);
    $res->request($self);
    $res;
}

sub finalize {
    my $self = shift;

    my ($path_info, $query_string) = $self->_path;

    $self->env->{PATH_INFO} = $path_info;
    $self->env->{QUERY_STRING} = $query_string || '';

    my $uri = $self->uri($path_info, $query_string || '');

    my $request =
      HTTP::Request->new( $self->method => $uri, $self->headers );

    $request->content($self->content) if ($self->content);
    $request;
}

1;

__END__

=head1 SYNOPSIS

    use Net::HTTP::Spore::Request;

    my $request = Net::HTTP::Spore::Request->new($env);

=head1 DESCRIPTION

Net::HTTP::Spore::Request create a HTTP request

=head1 METHODS

=over 4

=item new

    my $req = Net::HTTP::Spore::Request->new();

Creates a new Net::HTTP::Spore::Request object.

=item env

    my $env = $request->env;

Get the environment for the given request

=item method

    my $method = $request->method;

Get the HTTP method for the given request

=item port

    my $port = $request->port;

Get the HTTP port from the URL

=item script_name

    my $script_name = $request->script_name;

Get the script name part from the URL

=item path

=item path_info

    my $path = $request->path_info;

Get the path info part from the URL

=item request_uri

    my $request_uri = $request->request_uri;

Get the request uri from the URL

=item scheme

    my $scheme = $request->scheme;

Get the scheme from the URL

=item secure

    my $secure = $request->secure;

Return true if the URL is HTTPS

=item content

=item body

=item input

    my $input = $request->input;

Get the content that will be posted

=item query_string

=item headers

=item header

=item uri

=item query_parameters

=item base

=item new_response

=item finalize

=back
