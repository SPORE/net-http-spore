package Net::HTTP::Spore::Meta::Method;

# ABSTRACT: create api method

use Moose;
use Moose::Util::TypeConstraints;

use MooseX::Types::Moose qw/Str Int ArrayRef/;
use MooseX::Types::URI qw/Uri/;

extends 'Moose::Meta::Method';
use Net::HTTP::Spore::Response;

subtype UriPath
    => as 'Str'
    => where { $_ =~ m!^/! }
    => message {"path must start with /"};

enum Method => qw(HEAD GET POST PUT DELETE);

has path   => ( is => 'ro', isa => 'UriPath', required => 1 );
has method => ( is => 'ro', isa => 'Method',  required => 1 );
has description => ( is => 'ro', isa => 'Str', predicate => 'has_description' );

has authentication => (
    is => 'ro',
    isa => 'Bool',
    predicate => 'has_authentication',
    default => 0
);
has api_base_url => (
    is        => 'ro',
    isa       => Uri,
    coerce    => 1,
    predicate => 'has_api_base_url',
);
has expected => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef [Int],
    auto_deref => 1,
    required   => 0,
    predicate  => 'has_expected',
    handles    => {find_expected_code => 'grep',},
);
has params => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef [Str],
    required   => 0,
    default    => sub { [] },
    auto_deref => 1,
    handles    => {find_request_parameter => 'first',}
);
has required => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef [Str],
    default    => sub { [] },
    auto_deref => 1,
    required   => 0,
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
        $doc .= "arguments:   " . join(', ', $self->params) . "\n"
          if $self->params;
        $doc .= "required:    " . join(', ', $self->required) . "\n"
          if $self->required;
        $doc;
    }
);

sub wrap {
    my ( $class, %args ) = @_;

    my $code = sub {
        my ( $self, %method_args ) = @_;

        my $method = $self->meta->find_spore_method_by_name( $args{name} );

        my $payload =
          ( defined $method_args{spore_payload} )
          ? delete $method_args{spore_payload}
          : delete $method_args{payload};

        foreach my $required ( $method->required ) {
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

        my $params;
        foreach (keys %method_args) {
            push @$params, $_, $method_args{$_};
        }

        my $api_base_url =
            $method->has_api_base_url
          ? $method->api_base_url
          : $self->api_base_url;

        my $env = {
            REQUEST_METHOD => $method->method,
            SERVER_NAME    => $api_base_url->host,
            SERVER_PORT    => $api_base_url->port,
            SCRIPT_NAME    => (
                $api_base_url->path eq '/'
                ? ''
                : $api_base_url->path
            ),
            PATH_INFO              => $method->path,
            REQUEST_URI            => '',
            QUERY_STRING           => '',
            SERVER_PROTOCOL        => $api_base_url->scheme,
            HTTP_USER_AGENT        => $self->api_useragent->agent,
            'spore.expected'       => [ $method->expected ],
            'spore.authentication' => $method->authentication,
            'spore.params'         => $params,
            'spore.payload'        => $payload,
            'spore.errors'         => *STDERR,
            'spore.url_scheme'     => $api_base_url->scheme,
        };

        my $response = $self->http_request($env);
        my $code = $response->status;

        die $response if ( $method->has_expected
            && !$method->find_expected_code( sub { /$code/ } ) );

        $response;
    };
    $args{body} = $code;

    $class->SUPER::wrap(%args);
}

1;

=head1 SYNOPSIS

=head1 DESCRIPTION

