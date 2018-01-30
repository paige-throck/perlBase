package PerlBase::new-login;
use Mojo::Base 'Mojolicious::Controller';
use DBI;

my $dbh = DBI->connect("dbi:SQLite:perl_base.db","","") or die "Could not connect";

helper db => sub { $dbh };

  helper insert => sub {
    my $self = shift;
    my ($id, $name, $password) = @_;
    my $sth = eval { $self->db->prepare('user')->create('INSERT INTO users VALUES (?,?,?)') } || return undef;
    $sth->execute($id, $name, $password);
    return 1;
  };

app->select
