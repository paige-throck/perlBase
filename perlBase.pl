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
  my ($self, $name) = @_;
  $name ||= $self->stash->{name} || $self->session->{name};
  return {} unless $name;
  return $self->users->{$name} ||= {
    name => $name,
    items => {},
  };
};

get '/' => sub {
  my $self = shift;
  my $template = $self->session->{name} ? 'list' : 'login';
  $self->render($template);
};

get '/list/:name' => 'list';

get '/add' => sub {
  my $self = shift;
  my $link = $self->link($self->param('url'));
  $self->render('add', link => $link);
};

post '/add' => sub {
  my $self = shift;
  my $title = $self->param('title');
  $self->user->{items}{$title} = {
    title => $title,
    url => $self->param('url'),
    purchased => 0,
  };
  $self->redirect_to('/');
};

post '/update' => sub {
  my $self = shift;
  my $user = $self->user($self->param('user'));
  my $item = $user->{items}{$self->param('title')};
  $item->{purchased} = $self->param('purchased');
  $self->redirect_to('list', name => $user->{name});
};

post '/remove' => sub {
  my $self = shift;
  delete $self->user->{items}{$self->param('title')};
  $self->redirect_to('/');
};

post '/login' => sub {
  my $self = shift;
  if (my $name = $self->param('name')) {
    $self->session->{name} = $name;
  }
  $self->redirect_to('/');
};

any '/logout' => sub {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('/');
};

app->start;
