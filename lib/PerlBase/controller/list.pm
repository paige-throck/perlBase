package PerlBase::Controller::List;
use Mojo::Base 'Mojolicious::Controller';

sub show_add {
  my $self = shift;
  my $item =
  $self->render('add', item => $item);
}

sub do_add {
  my $self = shift;
  my %item = (
    user_item => $self->param('user_item'),
    completed => 0,
  );
  $self->model->add_item($self->user, \%item);
  $self->redirect_to('/');
}

sub update {
  my $self = shift;
  $self->model->update_item(
    {id => $self->param('id')},
    $self->param('completed')
  );
  $self->redirect_to('list', username => $self->param('username'));
}

sub remove {
  my $self = shift;
  $self->model->remove_item(
    {id => $self->param('id')},
  );
  $self->redirect_to('/');
}

1;
