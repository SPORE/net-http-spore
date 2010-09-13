package Net::HTTP::Spore::Role::Middleware;

use Moose::Role;

has middlewares => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => ['Array'],
    lazy => 1,
    default => sub { [] },
    auto_deref => 1,
    handles => { _add_middleware => 'push', _filter_middlewares => 'grep'},
);

sub _load_middleware {
    my ( $self, $mw, @args ) = @_;

    Class::MOP::load_class($mw);

    my $code = $mw->wrap( @args );
    $self->_add_middleware($code);
}

sub enable {
    my ($self, $mw, @args) = @_;

    if ($mw !~ /(?:^\+|Net\:\:HTTP\:\:Spore\:\:Middleware)/) {
        $mw = "Net::HTTP::Spore::Middleware::".$mw;
    }
    $self->_load_middleware($mw, @args);
    $self;
}

sub enable_if {
    my ($self, $cond, $mw, @args) = @_;
    $self;
}

sub reset_middlewares {
    my $self = shift;
    $self->middlewares([]);
}

1;
