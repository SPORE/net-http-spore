package Net::HTTP::Spore::Meta::Method;

# ABSTRACT: create api method

use JSON;
use Moose;
use Moose::Util::TypeConstraints;

use MooseX::Types::Moose qw/Str Int ArrayRef HashRef/;
use MooseX::Types::URI qw/Uri/;

extends 'Moose::Meta::Method';
use Net::HTTP::Spore::Response;

subtype UriPath
    => as 'Str'
    => where { $_ =~ m!^/! }
    => message {"path must start with /"};

enum Method => qw(OPTIONS HEAD GET POST PUT DELETE TRACE);

subtype 'JSON::XS::Boolean' => as 'JSON::XS::Boolean';
subtype 'JSON::PP::Boolean' => as 'JSON::PP::Boolean';
subtype 'Boolean'           => as Int => where { $_ eq 1 || $_ eq 0 };

coerce 'Boolean'
    => from 'JSON::XS::Boolean'
    => via {
        if ( JSON::is_bool($_) && $_ == JSON::true ) {
            return 1
        }
        return 0;
    }
    => from 'JSON::PP::Boolean'
    => via {
        if ( JSON::is_bool($_) && $_ == JSON::true ) {
            return 1;
        }
        return 0;
    }
    => from Str
    => via {
        if ($_ eq 'true') {
            return 1;
        }
        return 0;
    };

has path   => ( is => 'ro', isa => 'UriPath', required => 1 );
has method => ( is => 'ro', isa => 'Method',  required => 1 );
has description => ( is => 'ro', isa => 'Str', predicate => 'has_description' );

has required_payload => (
    is        => 'ro',
    isa       => 'Boolean',
    predicate => 'payload_is_required',
    lazy      => 1,
    default   => 0,
    coerce    => 1,
);
has authentication => (
    is        => 'ro',
    isa       => 'Boolean',
    predicate => 'has_authentication',
    default   => 0,
    coerce    => 1,
);
has base_url => (
    is        => 'ro',
    isa       => Uri,
    coerce    => 1,
    predicate => 'has_base_url',
);
has formats => (
    is        => 'ro',
    isa       => ArrayRef [Str],
    predicate => 'has_formats',
);
has headers => (
    is        => 'ro',
    isa       => HashRef [Str],
    predicate => 'has_headers',
);
has expected_status => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef [Int],
    auto_deref => 1,
    predicate  => 'has_expected_status',
    handles    => { find_expected_status => 'grep', },
);
has optional_params => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef [Str],
    predicate  => 'has_optional_params',
    auto_deref => 1,
);
has required_params => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef [Str],
    predicate  => 'has_required_params',
    auto_deref => 1,
);
has form_data => (
    traits     => ['Hash'],
    is         => 'ro',
    isa        => 'HashRef',
    predicate  => 'has_form_data',
    auto_deref => 1,
);
has documentation => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $doc;
        $doc .= "name:        " . $self->name . "\n";
        $doc .= "description: " . $self->description . "\n"
          if $self->has_description;
        $doc .= "method:      " . $self->method . "\n";
        $doc .= "path:        " . $self->path . "\n";
        $doc .= "optional params:    " . join(', ', $self->optional_params) . "\n"
          if $self->has_optional_params;
        $doc .= "required params:    " . join(', ', $self->required_params) . "\n"
          if $self->has_required_params;
        $doc;
    }
);

sub wrap {
    my ( $class, %args ) = @_;

    my $name = $args{name};
    my $code = sub {
        my ( $self, %method_args ) = @_;

        my $method = $self->meta->find_spore_method_by_name( $name );

        my $payload =
          ( defined $method_args{spore_payload} )
          ? delete $method_args{spore_payload}
          : delete $method_args{payload};

        if ( $payload
            && ( $method->method !~ /^P(?:OS|U)T$/i ) )
        {
            die Net::HTTP::Spore::Response->new( 599, [],
                { error => "payload requires a PUT or POST method" },
            );
        }

        if ( $method->payload_is_required && !$payload ) {
            die Net::HTTP::Spore::Response->new(
                599,
                [],
                {
                    error => "this method require a payload, and no payload is provided",
                }
            );
        }

        if ($method->has_required_params) {
            foreach my $required ( $method->required_params ) {
                if ( !grep { $required eq $_ } keys %method_args ) {
                    die Net::HTTP::Spore::Response->new(
                        599,
                        [],
                        {
                            error =>
                                "$required is marked as required but is missing",
                        }
                    );
                }
            }
        }

        my $params;
        foreach (keys %method_args) {
            push @$params, $_, $method_args{$_};
        }

        my $authentication =
          $method->has_authentication ? $method->authentication : $self->authentication;

        my $formats = $method->has_formats ? $method->formats : $self->formats;

        my $base_url =
            $method->has_base_url
          ? $method->base_url
          : $self->base_url;

        my $env = {
            REQUEST_METHOD => $method->method,
            SERVER_NAME    => $base_url->host,
            SERVER_PORT    => $base_url->port,
            SCRIPT_NAME    => (
                $base_url->path eq '/'
                ? ''
                : $base_url->path
            ),
            PATH_INFO               => $method->path,
            REQUEST_URI             => '',
            QUERY_STRING            => '',
            HTTP_USER_AGENT         => $self->api_useragent->agent,
            'spore.expected_status' => [ $method->expected_status ],
            'spore.authentication'  => $authentication,
            'spore.params'          => $params,
            'spore.payload'         => $payload,
            'spore.errors'          => *STDERR,
            'spore.url_scheme'      => $base_url->scheme,
            'spore.userinfo'        => $base_url->userinfo,
            'spore.formats'         => $formats,
        };

        $env->{'spore.form_data'} = $method->form_data
          if $method->has_form_data;

        $env->{'spore.headers'} = $method->headers if $method->has_headers;

        my $response = $self->http_request($env);
        my $code = $response->status;

        my $ok = ($method->has_expected_status)
            ? $method->find_expected_status( sub { $_ eq $code } )
            : $response->is_success; # only 2xx is success
        die $response if not $ok;

        $response;
    };
    $args{body} = $code;

    if ($args{'form-data'}){
        $args{'form_data'} = delete $args{'form-data'};
    }

    $class->SUPER::wrap(%args);
}

1;

=head1 SYNOPSIS

    my $spore_method = Net::HTTP::Spore::Meta::Method->wrap(
        'user_timeline',
        method => 'GET',
        path   => '/user/:name'
    );

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<path>

=item B<method>

=item B<description>

=item B<authentication>

=item B<base_url>

=item B<formats>

=item B<expected_status>

=item B<params>

=item B<documentation>

=back
