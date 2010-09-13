package Net::HTTP::Spore::Middleware::Format::XML;

use Moose;
extends 'Net::HTTP::Spore::Middleware::Format';

use XML::Simple;

sub accept_type  { ( 'Accept'       => 'text/xml' ); }
sub content_type { ( 'Content-Type' => 'text/xml' ) }
sub encode       { XMLout( $_[1] ) }
sub decode       { XMLin( $_[1] ) }

1;
