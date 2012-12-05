package Net::HTTP::Spore::Role::Middleware;

use Moose::Role;
use Scalar::Util qw/blessed/;

has middlewares => (
    is         => 'rw',
    isa        => 'ArrayRef',
    traits     => ['Array'],
    lazy       => 1,
    default    => sub { [] },
    auto_deref => 1,
    handles    => { _add_middleware => 'push', _filter_middlewares => 'grep' },
);

sub _load_middleware {
    my ( $self, $mw, $cond, @args ) = @_;

    Class::MOP::load_class($mw) unless blessed($mw);

    my $code = $mw->wrap( $cond, @args );
    $self->_trace_msg('== enabling middleware %s', $mw);
    $self->_add_middleware($code);
}

sub _complete_mw_name {
    my ($self, $mw) = @_;

    if ($mw =~ /^\+/) {
        $mw =~ s/^\+//;
    }
    elsif ($mw !~ /Net\:\:HTTP\:\:Spore\:\:Middleware/) {
        $mw = "Net::HTTP::Spore::Middleware::".$mw;
    }

    return $mw;
}

sub enable {
    my ($self, $mw, @args) = @_;

    confess "middleware name is missing" unless $mw;

    $self->enable_if(sub{1}, $mw, @args);
    $self;
}

sub enable_if {
    my ($self, $cond, $mw, @args) = @_;

    confess "condition must be a code ref" if (!$cond || ref $cond ne 'CODE');

    if(ref($mw) eq 'CODE'){ # anonymous middleware
        Class::MOP::load_class('Net::HTTP::Spore::Middleware');
        my $anon = Class::MOP::Class->create_anon_class(
            superclasses => ['Net::HTTP::Spore::Middleware'],
            methods => {
                call => $mw
            }
        );
        $mw = $anon->new_object;
    } else {
        $mw = $self->_complete_mw_name($mw);
    }
    $self->_load_middleware($mw, $cond, @args);
    $self;
}

sub reset_middlewares {
    my $self = shift;
    $self->middlewares([]);
}

1;
