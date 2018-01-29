#!/usr/bin/env perl

use Mojolicious::Lite;

# connect to database
use DBI;
my $dbh = DBI->connect("dbi:SQLite:perlBase.db","","") or die "Could not connect";

# add helper methods for interacting with database
helper db => sub { $dbh };

helper create_table => sub {
  my $self = shift;
  warn "Creating table 'people'\n";
  $self->db->do('CREATE TABLE people (name varchar(255), age int);');
};

helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM people') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($name, $age) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO people VALUES (?,?)') } || return undef;
  $sth->execute($name, $age);
  return 1;
};

# if statement didn't prepare, assume its because the table doesn't exist
app->select || app->create_table;

# setup base routes
any '/' => sub {
  my $self = shift;
  my $rows = $self->select;
  $self->stash( rows => $rows );
  $self->render('main/index');
};

# setup route which receives data and returns to /
any '/insert' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $age = $self->param('age');
  my $insert = $self->insert($name, $age);
  $self->redirect_to('/');
};

app->start;
