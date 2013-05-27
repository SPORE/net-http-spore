package Net::HTTP::Spore::Role::UserAgent;

# ABSTRACT: create UserAgent

use Moose::Role;
use LWP::UserAgent;

has api_useragent => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    lazy    => 1,
    handles => [qw/request/],
    default => sub {
        my $self = shift;
        my $ua = LWP::UserAgent->new();
		my $version = $Net::HTTP::Spore::VERSION || 'GIT';
        $ua->agent( "Net::HTTP::Spore v$version (Perl)" );
        $ua->env_proxy;
        $ua->max_redirect(0);
        return $ua;
    }
);

1;
