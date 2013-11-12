package Net::HTTP::Spore::Middleware::Auth::OAuth;

# ABSTRACT: middleware for OAuth authentication

use Moose;
use URI::Escape;
use Digest::SHA;
use MIME::Base64;

extends 'Net::HTTP::Spore::Middleware::Auth';

has [qw/oauth_consumer_key oauth_consumer_secret/] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has oauth_callback => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => 'oob',
);

has oauth_signature_method => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => 'HMAC-SHA1',
);

has [qw/oauth_token oauth_token_secret oauth_verifier realm/] => (
    is  => 'ro',
    isa => 'Str',
);

sub call {
    my ( $self, $req ) = @_;

    return unless $self->should_authenticate($req);

    my $oauth_params = {
        oauth_signature_method => $self->oauth_signature_method,
        oauth_consumer_key     => $self->oauth_consumer_key,
        oauth_token            => $self->oauth_token,
        oauth_verifier         => $self->oauth_verifier,
        oauth_version          => '1.0',
    };

    if ( !defined $oauth_params->{oauth_token} ) {
        $oauth_params->{oauth_callback} = $self->oauth_callback;
    }

    foreach my $k ( keys %$oauth_params ) {
        $oauth_params->{$k} = uri_escape( $oauth_params->{$k} );
    }

    $req->finalize;

    my $oauth_sig = $self->_oauth_sig( $req, $oauth_params );
    $req->header( 'Authorization' =>
          $self->_build_auth_string( $oauth_params, $oauth_sig ) );
}

sub _base_string {
    my ($self, $req, $oparams) = @_;

    my $query_keys = [];
    my $query_vals = {};

    if ( defined $req->env->{QUERY_STRING} ) {
        while ($req->env->{QUERY_STRING} =~ /([^=]+)=([^&]*)&?/g){
            my ($k,$v) = ($1,$2);
            push @$query_keys, $k;
            $query_vals->{$k} = $v;
        }
    }

    my $payload = $req->body;
    if ( defined $payload ) {
        my $ct = $req->header('content-type');
        if ( !defined $ct or $ct eq 'application/x-www-form-urlencoded' ) {
            while ($payload =~ /([^=]+)=([^&]*)&?/g){
                my ($k,$v) = ($1,$2);
                $v =~ s/\+/\%\%20/;
                push @$query_keys, $k;
                $query_vals->{$k} = $v;
            }
        }
    }

    my $scheme = $req->scheme;
    my $port   = $req->port;

    if ( $port == 80 && $scheme eq 'http' ) {
        $port = undef;
    }
    if (   defined $port
        && defined $scheme
        && $port == 443
        && $scheme eq 'https' )
    {
        $port = undef;
    }


    my $uri =
        ( $scheme || 'https' ) . "://"
      . $req->env->{SERVER_NAME};
    if ( $port ) { $uri .= ":$port"; }
    $uri .=  $req->env->{SCRIPT_NAME}
           . $req->env->{PATH_INFO};


    foreach my $k (keys %$oparams){
        push @$query_keys, $k;
        $query_vals->{$k} = $oparams->{$k};
    }

    my @sort = sort {$a cmp $b} @$query_keys;
    my $params = [];

    foreach my $k (@sort){
        my $v = $query_vals->{$k};
        push @$params, $k . '=' . $v if defined $v;
    }
    my $normalized = join('&', @$params);
    my $str = uc($req->method) . '&' . uri_escape($uri) . '&' . uri_escape($normalized);
    return $str;
}

sub _build_auth_string {
    my ( $self, $oauth_params, $oauth_sig ) = @_;

    my $auth = 'OAuth';

    if ( $self->realm ) {
        $auth = $auth . ' realm="' . $self->realm . '",';
    }

    $auth =
        $auth
      . ' oauth_consumer_key="'
      . $oauth_params->{oauth_consumer_key} . '"'
      . ', oauth_signature_method="'
      . $oauth_params->{oauth_signature_method} . '"'
      . ', oauth_signature="'
      . $oauth_sig . '"';

    if ( $oauth_params->{oauth_signature_method} ne 'PLAINTEXT' ) {
        $auth =
            $auth
          . ', oauth_timestamp="'
          . $oauth_params->{oauth_timestamp} . '"'
          . ', oauth_nonce="'
          . $oauth_params->{oauth_nonce} . '"';
    }

    if ( !$oauth_params->{oauth_token} ) {
        $auth =
          $auth . ', oauth_callback="' . $oauth_params->{oauth_callback} . '"';
    }
    else {
        if ( $oauth_params->{oauth_verifier} ) {
            $auth =
                $auth
              . ', oauth_token="'
              . $oauth_params->{oauth_token} . '"'
              . ', oauth_verifier="'
              . $oauth_params->{oauth_verifier} . '"';
        }
        else {
            $auth =
              $auth . ', oauth_token="' . $oauth_params->{oauth_token} . '"';
        }
    }

    $auth = $auth . ', oauth_version="' . $oauth_params->{oauth_version} . '"';
    return $auth;
}

sub _oauth_sig {
    my ( $self, $req, $oauth_params ) = @_;

    die $oauth_params->{oauth_signature_method} . " is not supported"
      unless ( $oauth_params->{oauth_signature_method} eq 'PLAINTEXT'
        || $oauth_params->{oauth_signature_method} eq 'HMAC-SHA1' );

    if ( $oauth_params->{oauth_signature_method} eq 'PLAINTEXT' ) {
        return uri_escape( $self->_signature_key );
    }

    $oauth_params->{oauth_timestamp} = time;
    $oauth_params->{oauth_nonce}     = $self->_oauth_nonce;

    my $oauth_signature_base_string = $self->_base_string( $req, $oauth_params );

    return uri_escape(
        MIME::Base64::encode_base64(
            Digest::SHA::hmac_sha1(
                $oauth_signature_base_string, $self->_signature_key
            )
        )
    );
}

sub _oauth_nonce {
    Digest::SHA::sha1_hex( rand() . 'random' . time() . 'keyyy' );
}

sub _signature_key {
    my $self = shift;
    my $signature_key =
        uri_escape( $self->oauth_consumer_secret ) . '&'
      . uri_escape( $self->oauth_token_secret || '' );
    return $signature_key;
}

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec( 'google-url-shortener.json' );
    $client->enable('Format::JSON');
    $client->enable('Auth::OAuth',
        oauth_consumer_key    => '00000000.apps.googleusercontent.com',
        oauth_consumer_secret => 'xxxxxxxxx',
        oauth_token           => 'yyyyyyyyy',
        oauth_token_secret    => 'zzzzzzzzz',
    );

    my $r = $client->insert( payload => { longUrl => 'http://f.lumberjaph.net/' } );
    say( $r->body->{id} . ' is ' . $r->body->{longUrl} );
    say "list >";
    $r = $client->list();
    foreach my $short (@{$r->body->{items}}){
       say $short->{id} . '  ' . $short->{longUrl};
    }

=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::Auth::OAuth is a middleware to handle OAuth mechanism. This middleware should be loaded as the last middleware, because it requires all parameters to be setted to calculate the signature.
