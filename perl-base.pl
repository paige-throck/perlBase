#!/usr/bin/env perl

use Mojolicious::Lite;

# connect to database
use DBI;
my $dbh = DBI->connect("dbi:SQLite:perl_base.db","","") or die "Could not connect";

# add helper methods for interacting with database
helper db => sub { $dbh };

#User Table
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
helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM to_do_list') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($user_id, $item) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO to_do_list VALUES (?,?)') } || return undef;
  $sth->execute($user_id, $item);
  return 1;
};

#movers
helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM movers') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($id, $company, $phone_num, $website) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO movers VALUES (?,?,?,?)') } || return undef;
  $sth->execute($id, $company, $phone_num, $website);
  return 1;
};

# Moving_Day table

helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM moving_day') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($user_id, $mover_id, $new_address, $date) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO moving_day VALUES (?,?,?,?)') } || return undef;
  $sth->execute($user_id, $mover_id, $new_address, $date);
  return 1;
};

# if statement didn't prepare, assume its because the table doesn't exist
app->select


# setup base routes;
any '/' => sub {
  my $self = shift;
  my $rows = $self->select;
  $self->stash( rows => $rows );
  $self->render('main/index');
};

any '/insert' => sub {
  my $self = shift;
  my $item = $self->param('item');
  my $insert = $self->insert($item);
  $self->redirect_to('/');
};

any '/new' => sub {
  my $self = shift;
  my $rows = $self->select;
  $self->stash( rows => $rows );
  $self->render('login/login');
};

any '/new/insert' => sub {
  my $self = shift;
  my $id = $self->param('id');
  my $name = $self->param('name');
  my $password = $self->param('password');
  my $insert = $self->insert($id, $name, $password);
  $self->redirect_to('/');
};

app->start;
