package Net::HTTP::Spore::Request;

# ABSTRACT: Net::HTTP::Spore::Request - Portable HTTP request object from SPORE env hash

use Moose;
use Carp ();
use URI;
use HTTP::Headers;
use HTTP::Request;
use URI::Escape;
use MIME::Base64;
use Net::HTTP::Spore::Response;

use Encode qw{is_utf8};

has env => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
    traits   => ['Hash'],
    handles  => {
        set_to_env   => 'set',
        get_from_env => 'get',
    }
);

has path => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->env->{PATH_INFO} }
);

has headers => (
    is      => 'rw',
    isa     => 'HTTP::Headers',
    lazy    => 1,
    handles => {
        header => 'header',
    },
    default => sub {
        my $self = shift;
        my $env  = $self->env;
        my $h    = HTTP::Headers->new(
            map {
                ( my $field = $_ ) =~ s/^HTTPS?_//;
                ( $field => $env->{$_} );
              } grep { /^(?:HTTP|CONTENT)/i } keys %$env
        );
        return $h;
    },
);

sub BUILDARGS {
    my $class = shift;

    if ( @_ == 1 && !exists $_[0]->{env} ) {
        return { env => $_[0] };
    }
    return @_;
}

sub _safe_uri_escape {
    my ( $self, $str, $unsafe ) = @_;
    if ( is_utf8($str) ) {
        utf8::encode($str);
    }
    return uri_escape( $str, $unsafe );
}

sub method {
    my ( $self, $value ) = @_;
    if ($value) {
        $self->set_to_env( 'REQUEST_METHOD', $value );
    }
    else {
        return $self->get_from_env('REQUEST_METHOD');
    }
}

sub host {
    my ($self, $value) = @_;
    if ($value) {
        $self->set_to_env('SERVER_NAME', $value);
    }else{
        return $self->get_from_env('SERVER_NAME');
    }
}

sub port {
    my ( $self, $value ) = @_;
    if ($value) {
        $self->set_to_env( 'SERVER_PORT', $value );
    }
    else {
        return $self->get_from_env('SERVER_PORT');
    }
}

sub script_name {
    my ( $self, $value ) = @_;
    if ($value) {
        $self->set_to_env( 'SCRIPT_NAME', $value );
    }
    else {
        return $self->get_from_env('SCRIPT_NAME');
    }
}

sub request_uri {
    my ($self, $value) = @_;
    if ($value) {
        $self->set_to_env( 'REQUEST_URI', $value );
    }
    else {
        return $self->get_from_env('REQUEST_URI');
    }
}

sub scheme {
    my ($self, $value) = @_;
    if ($value) {
        $self->set_to_env( 'spore.url_scheme', $value );
    }
    else {
        return $self->get_from_env('spore.url_scheme');
    }
}

sub logger {
    my ($self, $value) = @_;
    if ($value) {
        $self->set_to_env( 'sporex.logger', $value );
    }
    else {
        return $self->get_from_env('sporex.logger');
    }
}

sub body {
    my ($self, $value) = @_;
    if ($value) {
        $self->set_to_env( 'spore.payload', $value );
    }
    else {
        return $self->get_from_env('spore.payload');
    }
}

sub base {
    my $self = shift;
    URI->new( $self->_uri_base )->canonical;
}

sub input   { (shift)->body(@_) }
sub content { (shift)->body(@_) }
sub secure  { $_[0]->scheme eq 'https' }

# TODO
# need to refactor this method, with path_info and query_string construction
sub uri {
    my ($self, $path_info, $query_string) = @_;

    if ( !defined $path_info || !defined $query_string ) {
        my @path_info = $self->_path;
        $path_info    = $path_info[0] if !$path_info;
        $query_string = $path_info[1] if !$query_string;
    }

    my $base = $self->_uri_base;

    my $path_escape_class = '^A-Za-z0-9\-\._~/';
    my $path = $self->_safe_uri_escape( $path_info || '', $path_escape_class );

    if ( defined $query_string && length($query_string) > 0 ) {
        my $is_interrogation = index( $path, '?' );
        if ( $is_interrogation >= 0 ) {
            $path .= '&' . $query_string;
        }
        else {
            $path .= '?' . $query_string;
        }
    }

    $base =~ s!/$!! if $path =~ m!^/!;
    return URI->new( $base . $path )->canonical;
}

sub _path {
    my $self = shift;

    my $query_string;
    my $path = $self->env->{PATH_INFO};
    my @params = @{ $self->env->{'spore.params'} || [] };

    my $j = 0;
    for ( my $i = 0; $i < scalar @params; $i++ ) {
        my $key = $params[$i];
        my $value = $params[++$i];
        $value = (defined $value) ? $value : '' ;
        if (! length($value)) {
            $query_string .= $key;
            last;
        }

        # add params as string vide to query_string even it's undefined
        unless ( $path && $path =~ s/\:$key/$value/ ) {
            $query_string .= $key . '=' . $self->_safe_uri_escape($value);
            $query_string .= '&' if $query_string && scalar @params;
        }
    }

    $query_string =~ s/&$// if $query_string;
    $self->env->{QUERY_STRING} = $query_string;

    return ( $path, $query_string );
}

sub _uri_base {
    my $self = shift;
    my $env  = $self->env;

    my $uri =
      ( $env->{'spore.url_scheme'} || "http" ) . "://"
      . (
        defined $env->{'spore.userinfo'}
        ? $env->{'spore.userinfo'} . '@'
        : ''
      )
      . (
        $env->{HTTP_HOST}
          || (( $env->{SERVER_NAME} || "" ) . ":"
            . ( $env->{SERVER_PORT} || 80 ) )
      ) . ( $env->{SCRIPT_NAME} || '/' );

    return $uri;
}

# stolen from HTTP::Request::Common
sub _boundary {
    my ( $self, $size ) = @_;

    return "xYzZy" unless $size;

    my $b =
      MIME::Base64::encode( join( "", map chr( rand(256) ), 1 .. $size * 3 ),
        "" );
    $b =~ s/[\W]/X/g;
    return $b;
}

sub _form_data {
    my ( $self, $data ) = @_;

    my $form_data;
    foreach my $k ( keys %$data ) {
        push @$form_data,
            'Content-Disposition: form-data; name="'
          . $k
          . '"'."\r\n\r\n"
          . $data->{$k};
    }

    my $b = $self->_boundary(10);
    my $t = [];
    foreach (@$form_data) {
        push @$t, '--', $b, "\r\n", $_, "\r\n";
    }
    push @$t, '--', $b, , '--', "\r\n";
    my $content = join("", @$t);
    return ($content, $b);
}

sub new_response {
    my $self = shift;
    my $res = Net::HTTP::Spore::Response->new(@_);
    $res->request($self);
    $res;
}

sub finalize {
    my $self = shift;

    my $path_info = $self->env->{PATH_INFO};

    my $form_data = $self->env->{'spore.form_data'};
    my $headers   = $self->env->{'spore.headers'};
    my $params    = $self->env->{'spore.params'} || [];

    my $query = [];
    my $form  = {};

    for ( my $i = 0 ; $i < scalar @$params ; $i++ ) {
        my $k = $params->[$i];
        my $v = $params->[++$i];
        my $modified = 0;

        if ($path_info && $path_info =~ s/\:$k/$v/) {
            $modified++;
        }

        foreach my $f_k (keys %$form_data) {
            my $f_v = $form_data->{$f_k};
            if ($f_v =~ s/^\:$k/$v/) {
                $form->{$f_k} = $f_v;
                $modified++;
            }
        }

        foreach my $h_k (keys %$headers) {
            my $h_v = $headers->{$h_k};
            if ($h_v =~ s/^\:$k/$v/) {
                $self->header($h_k => $h_v);
                $modified++;
            }
        }

        if ($modified == 0) {
            if (defined $v) {
                push @$query, $k.'='.$v;
            }else{
                push @$query, $k;
            }
        }
    }

    # clean remaining :name in url
    $path_info =~ s/:\w+//g if $path_info;

    my $query_string;
    if (scalar @$query) {
        $query_string = join('&', @$query);
    }

    $self->env->{PATH_INFO}    = $path_info;
    $self->env->{QUERY_STRING} = $query_string;

    my $uri = $self->uri($path_info, $query_string || '');

    my $request = HTTP::Request->new(
        $self->method => $uri, $self->headers
    );

    if ( keys %$form_data ) {
        $self->env->{'spore.form_data'} = $form;
        my ( $content, $b ) = $self->_form_data($form);
        $request->content($content);
        $request->header('Content-Length' => length($content));
        $request->header(
            'Content-Type' => 'multipart/form-data; boundary=' . $b );
    }

    if ( my $payload = $self->content ) {
        $request->content($payload);
        $request->header(
            'Content-Type' => 'application/x-www-form-urlencoded' )
          unless $request->header('Content-Type');
    }

    return $request;
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
