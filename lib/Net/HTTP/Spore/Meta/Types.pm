package Net::HTTP::Spore::Meta::Types;

# ABSTRACT: Moose type definitions for Net::HTTP::Spore

use Moose::Util::TypeConstraints;
use MooseX::Types -declare => [ qw(UriPath Boolean HTTPMethod JSONBoolean) ];
use MooseX::Types::Moose qw(Str Int Defined);
use JSON;

subtype UriPath,
    as Str,
    where { $_ =~ m!^/! },
    message {"path must start with /"};

enum HTTPMethod, [qw(OPTIONS HEAD GET POST PUT DELETE TRACE PATCH)];

subtype Boolean,
    as Int,
    where { $_ eq 1 || $_ eq 0 };

subtype JSONBoolean,
    as Defined,
    where { JSON::is_bool($_) };

coerce Boolean,
    from JSONBoolean,
      via { return int($_) ? 1 : 0 },
    from Str,
      via { return $_ eq 'true' ? 1 : 0 };

1;
