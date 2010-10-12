package Net::HTTP::Spore::Meta;

# ABSTRACT: Meta class for all SPORE object

use Moose;
use Moose::Exporter;
use Moose::Util::MetaRole;

our $VERSION = '0.14';

Moose::Exporter->setup_import_methods(
    with_meta => [qw/spore_method/],
    also      => [qw/Moose/]
);

sub spore_method {
    my $meta = shift;
    my $name = shift;
    $meta->add_spore_method($name, @_);
}

sub init_meta {
    my ($class, %options) = @_;

    my $for = $options{for_class};
    Moose->init_meta(%options);

    my $meta = Moose::Util::MetaRole::apply_metaroles(
        for       => $for,
        class_metaroles => {
            class => ['Net::HTTP::Spore::Meta::Class'],
        },
    );

    Moose::Util::MetaRole::apply_base_class_roles(
        for   => $for,
        roles => [
            qw/
              Net::HTTP::Spore::Role::Description
              Net::HTTP::Spore::Role::UserAgent
              Net::HTTP::Spore::Role::Request
              Net::HTTP::Spore::Role::Middleware
              /
        ],
    );

    $meta;
};

1;
