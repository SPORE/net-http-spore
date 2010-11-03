use strict;
use warnings;
use Test::More;

use Net::HTTP::Spore::Request;

my @tests = (
    {
        add_env => {
            HTTP_HOST   => 'example.com',
            SCRIPT_NAME => "",
        },
        uri        => 'http://example.com/',
        parameters => {}
    },
    {
        add_env => {
            HTTP_HOST   => 'example.com',
            SCRIPT_NAME => "",
            PATH_INFO   => "/foo bar",
        },
        uri        => 'http://example.com/foo%20bar',
        parameters => {}
    },
    {
        add_env => {
            HTTP_HOST   => 'example.com',
            SCRIPT_NAME => '/test.c',
        },
        uri        => 'http://example.com/test.c',
        parameters => {}
    },
    {
        add_env => {
            HTTP_HOST   => 'example.com',
            SCRIPT_NAME => '/test.c',
            PATH_INFO   => '/info',
        },
        uri        => 'http://example.com/test.c/info',
        parameters => {}
    },
    {
        add_env => {
            HTTP_HOST    => 'example.com',
            SCRIPT_NAME  => '/test',
            'spore.params' => [qw/dynamic daikuma/],
        },
        uri        => 'http://example.com/test?dynamic=daikuma',
        parameters => { dynamic => 'daikuma' }
    },
    {
        add_env => {
            HTTP_HOST   => 'example.com',
            SCRIPT_NAME => '/exec/'
        },
        uri        => 'http://example.com/exec/',
        parameters => {}
    },
    {
        add_env    => { SERVER_NAME => 'example.com' },
        uri        => 'http://example.com/',
        parameters => {}
    },
    {
        add_env    => {},
        uri        => 'http:///',
        parameters => {}
    },
    {
        add_env => {
            HTTP_HOST    => 'example.com',
            SCRIPT_NAME  => "",
            'spore.params' => [qw/aco tie/],
        },
        uri        => 'http://example.com/?aco=tie',
        parameters => { aco => 'tie' }
    },
    {
        add_env => {
            HTTP_HOST    => 'example.com',
            SCRIPT_NAME  => "",
            'spore.params' => [qw/0/],
        },
        uri        => 'http://example.com/?0',
        parameters => {}
    },
    {
        add_env => {
            HTTP_HOST   => 'example.com',
            SCRIPT_NAME => "/foo bar",
            PATH_INFO   => "/baz quux",
        },
        uri        => 'http://example.com/foo%20bar/baz%20quux',
        parameters => {}
    },
    {
        add_env => {
            HTTP_HOST      => 'example.com',
            SCRIPT_NAME    => '',
            PATH_INFO      => '/:foo/:bar/:baz',
            'spore.params' => [qw/foo foo bar bar/]
        },
        uri        => 'http://example.com/foo/bar/',
        parameters => { foo => 'foo', bar => 'bar' },
    }
);

plan tests => 1 * @tests;

for my $block (@tests) {
    my $env = { SERVER_PORT => 80 };
    while ( my ( $key, $val ) = each %{ $block->{add_env} || {} } ) {
        $env->{$key} = $val;
    }
    my $req = Net::HTTP::Spore::Request->new($env)->finalize;

    is $req->uri,                     $block->{uri};
#    is_deeply $req->query_parameters, $block->{parameters};
}
