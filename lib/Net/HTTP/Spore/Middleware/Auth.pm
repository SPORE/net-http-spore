package Net::HTTP::Spore::Middleware::Auth;

# ABSTRACT: base class for Authentication middlewares

use Moose;
extends 'Net::HTTP::Spore::Middleware';

sub should_authenticate { $_[1]->env->{'spore.authentication'} }

sub call { die "should be implemented" }

1;

=head1 DESCRIPTION

Authentication middleware should extends this base class and implement the B<call> method
