package Net::HTTP::Spore::Middleware::Redirection;

use Moose;

extends 'Net::HTTP::Spore::Middleware';

with 'Net::HTTP::Spore::Role::Request', 'Net::HTTP::Spore::Role::UserAgent';

has max_redirect => ( is => 'rw', isa => 'Int', lazy => 1, default => 5 );

sub call {
    my ( $self, $req ) = @_;

    my $nredirect = 0;

    return $self->response_cb(
        sub {
            my $res      = shift;
            while ( $nredirect < $self->max_redirect ) {
                my $location = $res->header('location');
                my $status   = $res->status;
                if (
                    $location
                    and (  $status == 301
                        or $status == 302
                        or $status == 303
                        or $status == 307 )
                  )
                {
                    my $uri = URI->new($location);
                    $req->env->{HTTP_HOST}   = $uri->host;
                    $req->env->{PATH_INFO}   = $uri->path;
                    $req->env->{SERVER_PORT} = $uri->port;
                    $req->env->{SERVER_NAME} = $uri->host;
                    $res = $self->_request($req);
                    $nredirect++;
                }else{
                    last;
                }
            }
            return $res;
        }
    );
}

1;
