package Net::HTTP::Spore::Middleware::Format::XML;

# ABSTRACT: middleware for XML format

use Moose;
extends 'Net::HTTP::Spore::Middleware::Format';

use XML::Simple;

my @KnownOptIn     = qw(keyattr keeproot forcecontent contentkey noattr
                        searchpath forcearray cache suppressempty parseropts
                        grouptags nsexpand datahandler varattr variables
                        normalisespace normalizespace valueattr);

my @KnownOptOut    = qw(keyattr keeproot contentkey noattr
                        rootname xmldecl outputfile noescape suppressempty
                        grouptags nsexpand handler noindent attrindent nosort
                        valueattr numericescape);

sub accept_type  { ( 'Accept'       => 'text/xml' ); }
sub content_type { ( 'Content-Type' => 'text/xml' ) }
sub encode       { my $mw = $_[0];
                   my @args = map { $_ => $mw->{$_} } grep { $mw->{$_} } @KnownOptOut;
                   XMLout( $_[1], @args ) }
sub decode       { my $mw = $_[0];
                   my @args = map { $_ => $mw->{$_} } grep { $mw->{$_} } @KnownOptIn;
                   XMLin( $_[1], @args ) }

1;

=head1 SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
    $client->enable('Format::XML');

=head1 DESCRIPTION

Net::HTTP::Spore::Middleware::Format::XML is a simple middleware to handle the XML format. It will set the appropriate B<Accept> header in your request. If the request method is PUT or POST, the B<Content-Type> header will also be set to XML.

This middleware will also deserialize content in the response. The deserialized content will be store in the B<body> of the response.

=head1 EXAMPLES
