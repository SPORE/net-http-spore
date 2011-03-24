package Net::HTTP::Spore::Role;

use MooseX::Role::Parameterized;
use Net::HTTP::Spore;

parameter name => (isa => 'Str', required => 1);
parameter config => (isa => 'Str', required => 1);

role {
    my $p      = shift;
    my $name   = $p->name;
    my $config = $p->config;

    has $name => (
        is      => 'rw',
        isa     => 'Object',
        lazy    => 1,
        default => sub {
            my $self          = shift;
            my $client_config = $self->$config;
            my $client        = Net::HTTP::Spore->new_from_spec(
                $client_config->{spec},
                %{ $client_config->{options} },
            );
            foreach my $mw ( @{ $client_config->{middlewares} } ) {
                $client->enable($mw);
            }
            $client;
        },
    );

    has $config => (
        is      => 'rw',
        isa     => 'HashRef',
        lazy    => 1,
        default => sub { {} },
    );
};

1;

=head1 NAME

Net::HTTP::Spore::Role

=head1 DESCRIPTION

=head1 SYNOPSIS

  package my::app;
  use Moose;
  with Net::HTTP::Spore::Role => {name => 'twitter', config => 'twitter_config'};

  ...

  my $app = my::app->new(twitter_config => $config->{spore}->{twitter_config});
