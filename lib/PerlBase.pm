package PerlBase;
use Mojo::Base 'Mojolicious';

use Mojo::File;
use Mojo::SQLite;
use LinkEmbedder;
use PerlBase::Model;

# has dist_dir => sub {
#   return Mojo::File->new(
#     File::Share::dist_dir('PerlBase')
#   );
# };

has sqlite => sub {
  my $app = shift;

  # Database storage
  my $file = $app->config->{database} || 'perlBase.db';
  unless ($file =~ /^:/) {
    $file = Mojo::File->new($file);
    unless ($file->is_abs) {
      $file = $app->home->child("$file");
    }
  }

  my $sqlite = Mojo::SQLite->new
    ->from_filename("$file")
    ->auto_migrate(1);

  # attach migrations file
  $sqlite->migrations->from_file(
    $app->home->child('perlBase.sql')
  )->name('perlBase');

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

  # $app->renderer->paths([
  #   $app->dist_dir->child('templates'),
  # ]);


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
    $username ||= $self->stash->{username} || $self->session->{username};
    return {} unless $username;
    return $self->model->user($username) || {};
  });

  $app->helper(users => sub {
    my $self = shift;
    return $self->model->all_users;
  });

  my $r = $app->routes;
  $r->get('/' => sub {
    my $self = shift;
    my $template = $self->session->{username} ? 'list' : 'login';
    $self->render($template);
  });

  $r->get('/list/:username')->to(template => 'list')->name('list');

  $r->get('/add')->to('List#show_add')->name('show_add');
  $r->post('/add')->to('List#do_add')->name('do_add');

  $r->post('/update')->to('List#update')->name('update');
  $r->post('/remove')->to('List#remove')->name('remove');

  $r->get('/register')->to(template => 'register')->name('show_register');
  $r->post('/register')->to('Login#register')->name('do_register');
  $r->post('/login')->to('Login#login')->name('login');
  $r->any('/logout')->to('Login#logout')->name('logout');

}

1;
