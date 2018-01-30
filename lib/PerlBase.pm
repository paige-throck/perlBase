package PerlBase;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};

  # Router
  my $r = $self->routes;

   # GET / -> Landing Page
  $r->get('/')->to(template => 'home/index');

  # Login routes
  $r->get('/login')->name('login_form')->to(template => 'login/login_form');

  $r->get('/new')->name('new')->to(template => 'new-login/new');

  #List Routes and User Moving Day info
  $r->get('/list')->name('moving-day')->to(template => 'main/moving-day');


  # Movers Routes
  $r->get('/movers')->name('movers')->to(template => 'movers/movers');

}

1;
