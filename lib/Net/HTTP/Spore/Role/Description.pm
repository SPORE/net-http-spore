package Net::HTTP::Spore::Role::Description;

# ABSTRACT: attributes for API description

use Moose::Role;
use MooseX::Types::URI qw/Uri/;

has base_url => (
    is       => 'rw',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

has formats => (
    is        => 'rw',
    isa       => 'ArrayRef',
    predicate => 'has_formats',
);

has authentication => (
    is        => 'rw',
    isa       => 'Bool',
    predicate => 'has_authentication',
);

1;
