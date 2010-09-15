package Net::HTTP::Spore::Role::Description;

# ABSTRACT: attributes for API description

use Moose::Role;
use MooseX::Types::URI qw/Uri/;

has api_base_url => (
    is       => 'rw',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

has api_format => (
    is        => 'rw',
    isa       => 'ArrayRef',
    predicate => 'has_api_format',
);

has api_authentication => (
    is        => 'rw',
    isa       => 'Bool',
    predicate => 'has_api_authentication',
);

1;
