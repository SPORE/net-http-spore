package Net::HTTP::Spore::Role::Description;

# ABSTRACT: attributes for API description

use Moose::Role;
use MooseX::Types::Moose qw/ArrayRef/;
use MooseX::Types::URI qw/Uri/;
use Net::HTTP::Spore::Meta::Types qw/Boolean/;

has base_url => (
    is       => 'rw',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

has formats => (
    is        => 'rw',
    isa       => ArrayRef,
    predicate => 'has_formats',
);

has authentication => (
    is        => 'rw',
    isa       => Boolean,
    predicate => 'has_authentication',
    coerce    => 1,
);

has expected_status => (
    is      => 'rw',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

1;
