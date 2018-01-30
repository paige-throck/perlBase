package PerlBase::Controller::login;
use Mojo::Base 'Mojolicious::Controller';
use DBI;

my $dbh = DBI->connect("dbi:SQLite:perl_base.db","","") or die "Could not connect";
helper db => sub { $dbh };
