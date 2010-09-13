package Net::HTTP::Spore::Middleware::Format::JSON;

use JSON;
use Moose;
extends 'Net::HTTP::Spore::Middleware::Format';

has _json_parser => (
    is      => 'rw',
    isa     => 'JSON',
    lazy    => 1,
    default => sub { JSON->new->allow_nonref },
);

sub encode       { $_[0]->_json_parser->encode( $_[1] ); }
sub decode       { $_[0]->_json_parser->decode( $_[1] ); }
sub accept_type  { ( 'Accept' => 'application/json' ) }
sub content_type { ( 'Content-Type' => 'application/json' ) }

1;
