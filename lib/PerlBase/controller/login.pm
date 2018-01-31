package PerlBase::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';

sub login {
  my $self = shift;
  my $username = $self->param('username');
  my $password = $self->param('password');
  if ($self->model->check_password($username, $password)) {
    $self->session->{username} = $username;
  }
  $self->redirect_to('/');
}

sub register {
  my $self = shift;
  my $username = $self->param('username');
  my $user = {
    username => $username,
    password => $self->param('password'),
    name     => $self->param('name'),
  };
  print $user;
  warn Mojo::Util::dumper $user;
  unless(eval { $self->model->add_user($user); 1 }) {
    $self->app->log->error($@) if $@;
    return $self->render(text => 'Could not create user', status => 400);
  }
  $self->session->{username} = $username;
  $self->redirect_to('/');
};

sub logout {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('/');
}

1;
