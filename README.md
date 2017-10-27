# NAME

Net::HTTP::Spore - SPORE client

[![Build Status](https://travis-ci.org/SPORE/net-http-spore.svg?branch=master)](https://travis-ci.org/SPORE/net-http-spore)

# VERSION

version 0.09

# SYNOPSIS

    my $client = Net::HTTP::Spore->new_from_spec('twitter.json');

    # from JSON specification string
    my $client = Net::HTTP::Spore->new_from_string($json);

    # for identica
    my $client = Net::HTTP::Spore->new_from_spec('twitter.json', base_url => 'http://identi.ca/com/api');

    $client->enable('Format::JSON');

    my $timeline = $client->public_timeline(format => 'json');
    my $tweets = $timeline->body;

    foreach my $tweet (@$tweets) {
        print $tweet->{user}->{screen_name}. " says ".$tweet->{text}."\n";
    }

    my $friends_timeline = $client->friends_timeline(format => 'json');

# DESCRIPTION

This module is an implementation of the SPORE specification.

To use this client, you need to use or to write a SPORE specification of an
API.  A description of the SPORE specification format is available at
[http://github.com/SPORE/specifications/blob/master/spore\_description.pod](http://github.com/SPORE/specifications/blob/master/spore_description.pod)

Some specifications for well-known services are available
[http://github.com/SPORE/api-description](http://github.com/SPORE/api-description).

## CLIENT CREATION

First you need to create a client. This can be done using two methods,
**new\_from\_spec** and **new\_from\_string**. The client will read the specification
file to create the appropriate methods to interact with the API.

## MIDDLEWARES

It's possible to activate some middlewares to extend the usage of the client.
If you're using an API that discuss in JSON, you can enable the middleware
[Net::HTTP::Spore::Middleware::JSON](https://metacpan.org/pod/Net::HTTP::Spore::Middleware::JSON).

    $client->enable('Format::JSON');

or only on some path

    $client->enable_if(sub{$_->[0]->path =~ m!/path/to/json/stuff!}, 'Format::JSON');

For very simple middlewares, you can simply pass in an anonymous function

    $client->enable( sub { my $request = shift; ... } );

## METHODS

- new\_from\_spec($specification\_file, %args)

    Create and return a [Net::HTTP::Spore::Core](https://metacpan.org/pod/Net::HTTP::Spore::Core) object, with methods generated
    from the specification file. The specification file can either be a file on
    disk or a remote URL.

- new\_from\_string($specification\_string, %args)

    Create and return a [Net::HTTP::Spore::Core](https://metacpan.org/pod/Net::HTTP::Spore::Core) object, with methods
    generated from a JSON specification string.

## TRACING

[Net::HTTP::Spore](https://metacpan.org/pod/Net::HTTP::Spore) provides a way to trace what's going on when doing a
request.

### Enabling Trace

You can enable tracing using the environment variable **SPORE\_TRACE**. You can
also enable tracing at construct time by adding **trace => 1** when calling
**new\_from\_spec**.

### Trace Output

By default output will be directed to **STDERR**. You can specify another
default output:

    SPORE_TRACE=1=log.txt

or

    ->new_from_spec('spec.json', trace => '1=log.txt');

# AUTHORS

- Franck Cuny <franck.cuny@gmail.com>
- Ash Berlin <ash@cpan.org>
- Ahmad Fatoum <athreef@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Linkfluence.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
