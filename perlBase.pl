use Mojolicious::Lite;

use DBM::Deep;
use LinkEmbedder;

helper link => sub {
  my $self = shift;
  state $le = LinkEmbedder->new;
  return $le->get(@_);
};

helper users => sub {
  state $db = DBM::Deep->new('perl_base.db');
};

helper user => sub {
  my ($self, $name) = @_;
  $name ||= $self->stash->{name} || $c->session->{name};
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

get '/list/:name' => 'to_do_list/list';

post '/list/:name' => 'to_do_list/list' => sub {
  my $self = shift;
  my $item = $self->param('item');
  $self->user->{items}{$item} = {
    item => $item,
    url => $self->param('url'),
    purchased => 0,
  };
};

# post '/remove' => sub {
#   my $self = shift;
#   delete $self->user->{items}{$self->param('title')};
#   $self->redirect_to('/');
# };
#
# post '/login' => sub {
#   my $self = shift;
#   if (my $name = $self->param('name')) {
#     $self->session->{name} = $name;
#   }
#   $self->redirect_to('/');
# };
#
# any '/logout' => sub {
#   my $self = shift;
#   $self->session(expires => 1);
#   $self->redirect_to('/');
# };

app->start;
