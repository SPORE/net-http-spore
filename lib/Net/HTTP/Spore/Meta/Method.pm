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

enum Method => qw(HEAD GET POST PUT DELETE);

subtype 'JSON::XS::Boolean' => as 'JSON::XS::Boolean';
subtype 'JSON::PP::Boolean' => as 'JSON::PP::Boolean';
subtype 'Boolean'           => as 'Int' => where { $_ eq 1 || $_ eq 0 };

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
    => from 'Str'
    => via {
        if ($_ eq 'true') {
            return 1;
        }
        return 0;
    };

has path   => ( is => 'ro', isa => 'UriPath', required => 1 );
has method => ( is => 'ro', isa => 'Method',  required => 1 );
has description => ( is => 'ro', isa => 'Str', predicate => 'has_description' );

has authentication => (
    is        => 'ro',
    isa       => 'Boolean',
    predicate => 'has_authentication',
    default   => 0,
    coerce => 1,
);
has base_url => (
    is        => 'ro',
    isa       => Uri,
    coerce    => 1,
    predicate => 'has_base_url',
);
has format => (
    is        => 'ro',
    isa       => 'ArrayRef',
    isa       => ArrayRef [Str],
    predicate => 'has_format',
);
has expected => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => ArrayRef [Int],
    auto_deref => 1,
    predicate  => 'has_expected',
    handles    => { find_expected_code => 'grep', },
);
has params => (
    traits     => ['Hash'],
    is         => 'ro',
    isa        => HashRef [ArrayRef],
    lazy => 1,
    default    => sub { [] },
    auto_deref => 1,
    predicate => 'has_params',
);
has params_optional => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => ArrayRef [Str],
    default => sub {
        my $self = shift;
        return [] unless $self->has_params;
        my $opt = $self->params->{optional};
        $opt ? return $opt : return [];
    },
    predicate => 'has_optional_params',
    auto_deref => 1,
);
has params_required => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => ArrayRef [Str],
    default => sub {
        my $self = shift;
        return [] unless $self->has_params;
        my $req = $self->params->{required};
        $req ? return $req : return [];
    },
    predicate => 'has_required_params',
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
        $doc .= "optional:    " . join(', ', $self->params_optional) . "\n"
          if $self->has_optional_params;
        $doc .= "required:    " . join(', ', $self->params_required) . "\n"
          if $self->has_required_params;
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

        foreach my $required ( $method->params_required ) {
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

        my $authentication =
          $method->has_authentication ? $method->authentication : $self->authentication;

        my $format = $method->has_format ? $method->format : $self->api_format;

        my $api_base_url =
            $method->has_base_url
          ? $method->base_url
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
            HTTP_USER_AGENT        => $self->api_useragent->agent,
            'spore.expected'       => [ $method->expected ],
            'spore.authentication' => $authentication,
            'spore.params'         => $params,
            'spore.payload'        => $payload,
            'spore.errors'         => *STDERR,
            'spore.url_scheme'     => $api_base_url->scheme,
            'spore.format'         => $format,
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

=item B<format>

=item B<expected>

=item B<params>

=item B<documentation>

=back
