package Net::HTTP::Spore;

# ABSTRACT: SPORE client

use Moose;

use IO::All;
use JSON;
use Carp;
use Try::Tiny;

use Net::HTTP::Spore::Core;

our $VERSION = 0.01;

sub new_from_string {
    my ($class, $string, %args) = @_;

    my $spec;

    try {
        $spec = JSON::decode_json($string);
    }catch{
        Carp::confess("unable to parse JSON spec: ".$_);
    };

    my ( $spore_class, $spore_object );
    # XXX should we let the possibility to override this super class, or add
    # another superclasses?

    $spore_class =
      Class::MOP::Class->create_anon_class(
        superclasses => ['Net::HTTP::Spore::Core'] );

    try {
        my $api_base_url;
        if ( $spec->{api_base_url} && !$args{api_base_url} ) {
            $args{api_base_url} = $spec->{api_base_url};
        }
        elsif ( !$args{api_base_url} ) {
            die "api_base_url is missing!";
        }

        if ( $spec->{api_format} ) {
            $args{api_format} = $spec->{api_format};
        }

        if ( $spec->{authentication} ) {
            $args{authentication} = $spec->{authentication};
        }

        $spore_object = $spore_class->new_object(%args);
        $spore_object = _add_methods( $spore_object, $spec->{methods} );

    }
    catch {
        Carp::confess( "unable to create new Net::HTTP::Spore object: " . $_ );
    };

    return $spore_object;
}

sub new_from_spec {
    my ( $class, $spec_file, %args ) = @_;

    Carp::confess("specification file is missing") unless $spec_file;

    my ( $content, $spec );

    if ( $spec_file =~ m!^http(s)?://! ) {
        my $uri     = URI->new($spec_file);
        my $req = HTTP::Request->new(GET => $spec_file);
        my $ua  = LWP::UserAgent->new();
        my $res = $ua->request( $req );
        $content = $res->content;
    }
    else {
        unless ( -f $spec_file ) {
            Carp::confess("$spec_file does not exists");
        }
        $content < io($spec_file);
    }

    $class->new_from_string( $content, %args );
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

    $client->enable('Auth::OAuth');
    $client->enable('Format::JSON');

    my $timeline = $client->public_timeline(format => 'json');
    my $tweets = $timeline->body;
    foreach my $tweet (@$tweets) {
            print $tweet->{user}->{screen_name}. " says ".$tweet->{text}."\n";
        }
    }

    my $friends_timeline = $client->friends_timeline(format => 'json');

=head1 DESCRIPTION

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
