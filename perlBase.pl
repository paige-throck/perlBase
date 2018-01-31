use Mojolicious::Lite;

use DBM::Deep;
use LinkEmbedder;

helper link => sub {
  my $self = shift;
  state $le = LinkEmbedder->new;
  return $le->get(@_);
};

helper users => sub {
  state $db = DBM::Deep->new('perlBase.db');
};

helper user => sub {
  my ($self, $username,) = @_;
  $username ||= $self->stash->{username} || $self->session->{username};
  return {} unless $username;
  return $self->users->{$username} ||= {
    username => $username,
    items => {},
  };
};

get '/' => sub {
  my $self = shift;
  my $template = $self->session->{username} ? 'list' : 'login';
  $self->render($template);
};

get '/list/:username' => 'list';

get '/add' => sub {
  my $self = shift;
  my $item = $self->param('item');
  $self->render('add', item => $item);
};

post '/add' => sub {
  my $self = shift;
  my $item = $self->param('item');
  $self->user->{items}{$item} = {
    item => $item,
    completed => 0,
  };
  $self->redirect_to('/');
};

post '/update' => sub {
  my $self = shift;
  my $user = $self->user($self->param('username'));
  my $item = $user->{items}{$self->param('item')};
  $item->{completed} = $self->param('completed');
  $self->redirect_to('list', username => $user->{username});
};

post '/remove' => sub {
  my $self = shift;
  delete $self->user->{items}{$self->param('item')};
  $self->redirect_to('/');
};

post '/login' => sub {
  my $self = shift;
  if (my $username = $self->param('username')) {
    $self->session->{username} = $username;
  }
  $self->redirect_to('/');
};

any '/logout' => sub {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('/');
};

app->start;
