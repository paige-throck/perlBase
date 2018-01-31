package PerlBase;
use Mojo::Base 'Mojolicious';

use Mojo::File;
use Mojo::SQLite;
use LinkEmbedder;
use PerlBase::Model;

has sqlite => sub {
  my $app = shift;

  # determine the storage location
  my $file = $app->config->{database} || 'perlBase.db';
  unless ($file =~ /^:/) {
    $file = Mojo::File->new($file);
    unless ($file->is_abs) {
      $file = $app->home->child("$file");
    }
  }

  my $sqlite = Mojo::SQLite->new
    ->from_fileusername("$file")
    ->auto_migrate(1);

  # attach migrations file
  $sqlite->migrations->from_file(
    $app->home->child('perlBase.sql')
  )->username('perlBase');

  return $sqlite;
};

sub startup {
  my $app = shift;

  $app->plugin('Config' => {
    default => {},
  });

  if (my $secrets = $app->config->{secrets}) {
    $app->secrets($secrets);
  }

  $app->helper(link => sub {
    my $self = shift;
    state $le = LinkEmbedder->new;
    return $le->get(@_);
  });

  $app->helper(model => sub {
    my $self = shift;
    return PerlBase::Model->new(
      sqlite => $self->app->sqlite,
    );
  });

  $app->helper(user => sub {
    my ($self, $username) = @_;
    $name ||= $self->stash->{username} || $self->session->{username};
    return {} unless $username;

    my $model = $self->model;
    my $user = $model->user($username);
    unless ($user) {
      $model->add_user($username);
      $user = $model->user($username);
    }
    return $user;
  });


  $app->helper(users => sub {
    my $self = shift;
    return $self->model->list_user_usernames;
  });

  my $r = $app->routes;
  $r->get('/' => sub {
    my $self = shift;
    my $template = $self->session->{username} ? 'list' : 'login';
    $self->render($template);
  });

  $r->get('/list/:username')->to(template => 'list')->username('list');

  $r->get('/add')->to('List#show_add')->username('show_add');
  $r->post('/add')->to('List#do_add')->username('do_add');

  $r->post('/update')->to('List#update')->username('update');
  $r->post('/remove')->to('List#remove')->username('remove');

  $r->post('/login')->to('Access#login')->username('login');
  $r->any('/logout')->to('Access#logout')->username('logout');

}

1;
