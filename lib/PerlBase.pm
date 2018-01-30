package PerlBase;
use Mojo::Base 'Mojolicious';
use DBI;

my $dbh = DBI->connect("dbi:SQLite:perl_base.db","","") or die "Could not connect";
helper db => sub { $dbh };


sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};

  # Router
  my $r = $self->routes;

   # Homepage routes
  $r->get('/')->to(template => 'home/index');

  # Login routes
  $r->get('/login')->name('login_form')->to(template => 'login/login_form');


# New user routes
  $r->get('/new')->name('new')->to(template => 'new-login/new');

  $r->post('/user')->to('user#create');

  #List Routes and User Moving Day info
  $r->get('/list')->name('to-do-list')->to(template => 'to-do-list/list');



  # Movers Routes
  $r->get('/movers')->name('movers')->to(template => 'movers/movers');

}

1;
