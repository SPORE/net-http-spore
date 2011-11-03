package Net::HTTP::Spore::Middleware::Format::JSON;

# ABSTRACT: middleware for JSON format

use JSON;
use Moose;
extends 'Net::HTTP::Spore::Middleware::Format';

has utf8 => ( is => 'ro', isa => 'Bool', default => 1 );
has _json_parser => (
    is      => 'rw',
    isa     => 'JSON',
    lazy    => 1,
    default => sub { JSON->new->utf8(shift->utf8)->allow_nonref },
);

sub encode       { $_[0]->_json_parser->encode( $_[1] ); }
sub decode       { $_[0]->_json_parser->decode( $_[1] ); }
sub accept_type  { ( 'Accept' => 'application/json' ) }
sub content_type { ( 'Content-Type' => 'application/json;' ) }

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable('Format::JSON');
    
    # alternative to disable utf8 auto-encoding
    $client->enable('Format::JSON', utf8 => 0);
    
=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::Format::JSON is a simple middleware to handle the JSON format. It will set the appropriate B<Accept> header in your request. If the request method is PUT or POST, the B<Content-Type> header will also be set to JSON.

This middleware will also deserialize content in the response. The deserialized content will be store in the B<body> of the response.

=head1 EXAMPLES
