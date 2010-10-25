package Net::HTTP::Spore;

# ABSTRACT: SPORE client

use Moose;

use IO::All;
use JSON;
use Carp;
use Try::Tiny;
use Scalar::Util;

use Net::HTTP::Spore::Core;

our $VERSION = 0.01;

# XXX should we let the possibility to override this super class, or add
# another superclasses?

sub new_from_string {
    my ($class, $string, %args) = @_;

    my $spore_class =
      Class::MOP::Class->create_anon_class(
        superclasses => ['Net::HTTP::Spore::Core'] );

    my $spore_object = _attach_spec_to_class($string, \%args, $spore_class);

    return $spore_object;
}

sub new_from_strings {
    my $class = shift;

    my $opts;
    if (ref ($_[-1]) eq 'HASH') {
        $opts = pop @_;
    }
    my @strings = @_;

    my $spore_class =
      Class::MOP::Class->create_anon_class(
        superclasses => ['Net::HTTP::Spore::Core'] );

    my $spore_object = undef;
    foreach my $string (@strings) {
        $spore_object = _attach_spec_to_class($string, $opts, $spore_class, $spore_object);
    }
    return $spore_object;
}

sub new_from_spec {
    my ( $class, $spec_file, %args ) = @_;

    Carp::confess("specification file is missing") unless $spec_file;

    my $content = _read_spec($spec_file);

    $class->new_from_string( $content, %args );
}

sub new_from_specs {
    my $class = shift;

    my $opts;
    if (ref ($_[-1]) eq 'HASH') {
        $opts = pop @_;
    }
    my @specs = @_;

    my @strings;
    foreach my $spec (@specs) {
        push @strings,_read_spec($spec);
    }

    $class->new_from_strings(@strings, $opts);
}

sub _attach_spec_to_class {
    my ( $string, $opts, $class, $object ) = @_;

    my $spec;
    try {
        $spec = JSON::decode_json($string);
    }
    catch {
        Carp::confess( "unable to parse JSON spec: " . $_ );
    };

    try {
        my $base_url;
        if ( $spec->{base_url} && !$opts->{base_url} ) {
            $opts->{base_url} = $spec->{base_url};
        }
        elsif ( !$opts->{base_url} ) {
            die "base_url is missing!";
        }

        if ( $spec->{formats} ) {
            $opts->{formats} = $spec->{formats};
        }

        if ( $spec->{authentication} ) {
            $opts->{authentication} = $spec->{authentication};
        }

        if ( !$object ) {
            $object = $class->new_object(%$opts);
        }
        $object = _add_methods( $object, $spec->{methods} );
    }
    catch {
        Carp::confess( "unable to create new Net::HTTP::Spore object: " . $_ );
    };

    return $object;
}

sub _read_spec {
    my $spec_file = shift;

    my $content;

    if ( $spec_file =~ m!^http(s)?://! ) {
        my $uri = URI->new($spec_file);
        my $req = HTTP::Request->new( GET => $spec_file );
        my $ua  = LWP::UserAgent->new();
        my $res = $ua->request($req);
        $content = $res->content;
    }
    else {
        unless ( -f $spec_file ) {
            Carp::confess("$spec_file does not exists");
        }
        $content < io($spec_file);
    }

    return $content;
}

sub _add_methods {
    my ($class, $methods_spec) = @_;

    foreach my $method_name (keys %$methods_spec) {
        $class->meta->add_spore_method($method_name,
            %{$methods_spec->{$method_name}});
    }
    $class;
}

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');

    # for identica
    my $client = Net::HTTP::Spore->new_from_spec('twitter.json', base_url => 'http://identi.ca/com/api');

    $client->enable('Format::JSON');

    my $timeline = $client->public_timeline(format => 'json');
    my $tweets = $timeline->body;

    foreach my $tweet (@$tweets) {
        print $tweet->{user}->{screen_name}. " says ".$tweet->{text}."\n";
    }

    my $friends_timeline = $client->friends_timeline(format => 'json');

=head1 DESCRIPTION

This module is an implementation of the SPORE specification. To use this client, you need to use or to write a SPORE specification of an API. Some specifications are available L<http://github.com/SPORE/api-description>.

=head2 CLIENT CREATION

First you need to create a client. This can be done using two methods, B<new_from_spec> and B<new_from_string>. The client will read the specification file to create a appropriate methods to interact with the API.

=head2 MIDDLEWARES

It's possible to activate some middlewares to extend the usage of the client. If you're using an API that discuss in JSON, you can enable the middleware L<Net::HTTP::Spore::Middleware::JSON>.

    $client->enable('Format::JSON');

or only on some path

    $client->enable_if(sub{$_->[0]->path =~ m!/path/to/json/stuff!}, 'Format::JSON');

=head2 METHODS

=over 4

=item new_from_spec($specification_file, %args)

Create and return a L<Net::HTTP::Spore::Core> object, with methods
generated from the specification file. The specification file can
either be a file on disk or a remote URL.

=item new_from_string($specification_string, %args)

Create and return a L<Net::HTTP::Spore::Core> object, with methods
generated from the specification string.

=back
