package Net::HTTP::Spore::Role::Request;

# ABSTRACT: make HTTP request

use Try::Tiny;
use Moose::Role;

use Net::HTTP::Spore::Request;

sub http_request {
    my ( $self, $env ) = @_;

    my ($request, $response);
    $request = Net::HTTP::Spore::Request->new($env);

    my @middlewares;
    foreach my $mw ( $self->middlewares ) {
        my $res;
        try {
            $res = $mw->($request);
        }
        catch {
            $res = $request->new_response( 599, [], { error => $_, } );
        };

        if ( ref $res && ref $res eq 'CODE' ) {
            push @middlewares, $res;
        }
        elsif ( ref $res && ref $res eq 'Net::HTTP::Spore::Response' ) {
            return $res if ($res->status == 599);
            $response = $res;
            last;
        }
    }

    return
      $self->_execute_middlewares_on_response( $response, @middlewares )
      if defined $response;

    $response = $self->_request($request);

    return $self->_execute_middlewares_on_response( $response, @middlewares );
}

sub _execute_middlewares_on_response {
    my ($self, $response, @middlewares) = @_;

    foreach my $mw ( reverse @middlewares ) {
        my ($res, $error);
        try {
            $res = $mw->($response);
        }catch{
            $error = 1;
            $response->code(599);
            $response->body({error => $_, body=>$response->body});
        };
        $response = $res
          if ( defined $res
            && Scalar::Util::blessed($res)
            && $res->isa('Net::HTTP::Spore::Response') );
        last if $error;
    }

    $response;
}

sub _request {
    my ($self, $request) = @_;

    my $finalized_request = $request->finalize();

    $self->_debug_request($request, $finalized_request);

    my $result = $self->request($finalized_request);

    my $response = $request->new_response(
        $result->code,
        $result->headers,
        $result->content,
    );

    $self->_debug_response($response);

    return $response;
}

sub _debug_request {
    my ( $self, $request, $finalized_request ) = @_;
    return unless $self->trace;

    $self->_trace_msg( '> %s %s%s', $request->method, $request->script_name, $request->path );
    $self->_trace_msg( '> Host: %s', $request->host );
    $self->_trace_msg( '> Query String: %s', $request->env->{QUERY_STRING} )
      if defined $request->env->{QUERY_STRING};
    $self->_trace_msg( '> Content: %s', $request->content )
      if defined $request->content;

    foreach my $key ( $request->headers->header_field_names ) {
        $self->_trace_msg( '> %s: %s', $key, $request->header($key) );
    }
}

sub _debug_response {
    my ($self, $response) = @_;
    return unless $self->trace;

    foreach my $key ( $response->headers->header_field_names ) {
        $self->_trace_msg( '< %s: %s', $key, $response->header($key) );
    }
    $self->_trace_verbose($response->body);
}

1;

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item B<http_request>

=back

=head2 ATTRIBUTES

=over 4

=item B<api_base_url>

=back
