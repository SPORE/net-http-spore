use strict;
use warnings;
use 5.010;
use YAML::Syck;
use Net::HTTP::Spore;
use Try::Tiny;

my $api = Net::HTTP::Spore->new_from_spec(shift, api_base_url => 'http://localhost:5984');

$api->enable('Format::JSON');
$api->enable('Runtime');
$api->enable('UserAgent');

#my $documents = $api->get_all_documents(database => 'spore');
#warn Dump $documents;
#say "status => ".$documents->[0];
#say "body   => ".Dump $documents->[2];
#say "headers=> ".Dump $documents->[1];

my $res;

#$res = $api->create_document_with_id(database => 'spore', doc_id => 1, payload => {foo => 'bar'});
#warn Dump $res;

#$res = $api->delete_document(database =>'spore', doc_id => 1, rev => $res->body->{rev});
#warn Dump $res;

$res = $api->create_document_without_id(database => 'spore', payload => {foo => 'baz', bar => 'foobaz'});
warn Dump $res;

#try {
    #$res = $api->get_document( database => 'spore', doc_id => 1 );
#}
#catch {
    #warn Dump $_->[2];
    #warn Dump $_->[1];
#};

