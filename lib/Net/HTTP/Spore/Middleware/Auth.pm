package Net::HTTP::Spore::Middleware::Auth;

use Moose;
extends 'Net::HTTP::Spore::Middleware';

sub should_authenticate { $_[1]->env->{'spore.authentication'} }

sub call { die "should be implemented" }

1;
