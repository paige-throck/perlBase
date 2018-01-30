package PerlBase::Controller::Homepage;
use Mojo::Base 'Mojolicious::Controller';

any '/' => sub {
  my $self = shift;
  # my $rows = $self->select;
#   $self->stash( rows => $rows );
  $self->render('main/index');
# };
