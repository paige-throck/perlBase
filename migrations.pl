use Mojolicious::Lite;
use DBI;
my $dbh = DBI->connect("dbi:SQLite:perlBase.db","","") or die "Could not connect";

# $dbh->do("PRAGMA foreign_keys = ON");
# $dbh->do("PRAGMA primary_keys = ON");

# add helper methods for interacting with database
helper db => sub { $dbh };

# User Table
helper create_table => sub {
  my $self = shift;
  warn "Creating table 'users'\n";
  $self->db->do('CREATE TABLE users (id int, name varchar(255), password varchar(255));');
};

helper create_table => sub {
  my $self = shift;
  warn "Creating table 'to_do_list'\n";
  $self->db->do('CREATE TABLE to_do_list (user_id int, item varchar(255), completed bool);');
};

helper create_table => sub {
  my $self = shift;
  warn "Creating table 'movers'\n";
  $self->db->do('CREATE TABLE movers (id int, company varchar(255), phone_num varchar(255), address varchar(255);');
};

helper create_table => sub {
  my $self = shift;
  warn "Creating table 'moving_day'\n";
  $self->db->do('CREATE TABLE moving_day (user_id int, mover_id int, moving_date varchar(255))');
};

# User Table
helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM users') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($id, $name, $password) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO users VALUES (?,?,?)') } || return undef;
  $sth->execute($id, $name, $password);
  return 1;
};

# To Do List Table

# helper create_table => sub {
#   my $self = shift;
#   warn "Creating table 'to_do_list'\n";
#   $self->db->do('CREATE TABLE to_do_list (user_id int, item varchar(255), completed bool);');
# };

helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM to_do_list') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($user_id, $item, $completed) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO to_do_list VALUES (?,?,?)') } || return undef;
  $sth->execute($user_id, $item, $completed);
  return 1;
};

# Movers TABLE
# helper create_table => sub {
#   my $self = shift;
#   warn "Creating table 'movers'\n";
#   $self->db->do('CREATE TABLE movers (id int, company varchar(255), phone_num varchar(255), address varchar(255);');
# };

helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM movers') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($id, $company, $phone_num, $address) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO movers VALUES (?,?,?,?)') } || return undef;
  $sth->execute($id, $company, $phone_num, $address);
  return 1;
};

# Moving_Day table

# helper create_table => sub {
#   my $self = shift;
#   warn "Creating table 'moving_day'\n";
#   $self->db->do('CREATE TABLE moving_day (user_id int, mover_id int, moving_date varchar(255))');
# };

helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM moving_day') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($user_id, $mover_id, $moving_date) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO moving_day VALUES (?,?,?)') } || return undef;
  $sth->execute($user_id, $mover_id, $moving_date);
  return 1;
};

# if statement didn't prepare, assume its because the table doesn't exist
app->select || app->create_table;
