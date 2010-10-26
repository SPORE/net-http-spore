package Net::HTTP::Spore::Meta::Class;

# ABSTRACT: metaclass for all API client

use Moose::Role;

with qw/Net::HTTP::Spore::Meta::Method::Spore Net::HTTP::Spore::Role::Debug/;

1;

=head1 SYNOPSIS

=head1 DESCRIPTION
