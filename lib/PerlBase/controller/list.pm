package PerlBase::Controller::List;
use Mojo::Base 'Mojolicious::Controller';

sub show_add {
  my $self = shift;
  my $link = $self->link($self->param('url'));
  $self->render('add', link => $link);
}

sub do_add {
  my $self = shift;
  my %item = (
    title => $self->param('title'),
    url => $self->param('url'),
    purchased => 0,
  );
  $self->model->add_item($self->user, \%item);
  $self->redirect_to('/');
}

sub update {
  my $self = shift;
  $self->model->update_item(
    {id => $self->param('id')},
    $self->param('purchased')
  );
  $self->redirect_to('list', name => $self->param('name'));
}

sub remove {
  my $self = shift;
  $self->model->remove_item(
    {id => $self->param('id')},
  );
  $self->redirect_to('/');
}

1;
