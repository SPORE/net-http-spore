package Net::HTTP::Spore::Middleware::Format::YAML;

use YAML;
use Moose;
extends 'Net::HTTP::Spore::Middleware::Format';

sub encode       { YAML::Decode( $_[1] ); }
sub decode       { YAML::Load( $_[1] ); }
sub accept_type  { ( 'Accept' => 'text/x-yaml' ) }
sub content_type { ( 'Content-Type' => 'text/x-yaml' ) }

1;
