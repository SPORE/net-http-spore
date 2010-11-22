package Net::HTTP::Spore::Meta::Method::Spore;

# ABSTRACT: declare API method

use Moose::Role;
use Carp qw/confess/;

use Net::HTTP::Spore::Meta::Method;
use MooseX::Types::Moose qw/Str ArrayRef/;

has local_spore_methods => (
    traits     => ['Array'],
    is         => 'rw',
    isa        => ArrayRef [Str],
    required   => 1,
    default    => sub { [] },
    auto_deref => 1,
    handles    => {
        _find_spore_method_by_name => 'first',
        _add_spore_method          => 'push',
        get_all_spore_methods      => 'elements',
    },
);

sub find_spore_method_by_name {
    my ($meta, $name) = @_;
    my $method_name = $meta->_find_spore_method_by_name(sub {/^$name$/});
    return unless $method_name;
    my $method = $meta->find_method_by_name($method_name);
    if ($method->isa('Class::MOP::Method::Wrapped')) {
        return $method->get_original_method;
    }
    else {
        return $method;
    }
}

sub remove_spore_method {
    my ($meta, $name) = @_;
    my @methods = grep { !/$name/ } $meta->get_all_spore_methods;
    $meta->local_spore_methods(\@methods);
    $meta->remove_method($name);
}

before add_spore_method => sub {
    my ($meta, $name) = @_;
    if ($meta->_find_spore_method_by_name(sub {/^$name$/})) {
        confess "method '$name' is already delcared in ".$meta->name;
    }
};

sub add_spore_method {
    my ($meta, $name, %options) = @_;

    my $code = delete $options{code};

#    $meta->_trace_msg( '-> attach '
#          . $name . ' ('
#          . $options{method} . ' => '
#          . $options{path}
#          . ')' );

    $meta->add_method(
        $name,
        Net::HTTP::Spore::Meta::Method->wrap(
            name         => $name,
            package_name => $meta->name,
            body         => $code,
            %options
        ),
    );
    $meta->_add_spore_method($name);
}

after add_spore_method => sub {
    my ($meta, $name) = @_;
    $meta->add_before_method_modifier(
        $name,
        sub {
            my $self = shift;
            die Net::HTTP::Spore::Response->new(599, [], {error => "'base_url' have not been defined"}) unless $self->base_url;
        }
    );
};

1;

=head1 SYNOPSIS

    my $api_client = MyAPI->new;

    my @methods    = $api_client->meta->get_all_api_methods();

    my $method     = $api_client->meta->find_spore_method_by_name('users');

    $api_client->meta->remove_spore_method($method);

    $api_client->meta->add_spore_method('users', sub {...},
        description => 'this method does...',);

=head1 DESCRIPTION

=method get_all_spore_methods

Return a list of net api methods

=method find_spore_method_by_name

Return a net api method

=method remove_spore_method

Remove a net api method

=method add_spore_method

Add a net api method
