#!/usr/bin/env perl

use Mojolicious::Lite;

# connect to database
use DBI;
my $dbh = DBI->connect("dbi:SQLite:perlBase.db","","") or die "Could not connect";

# add helper methods for interacting with database
helper db => sub { $dbh };

helper create_table => sub {
  my $self = shift;
  warn "Creating table 'users'\n";
  $self->db->do('CREATE TABLE users (name varchar(255), password varchar(255));');
};

helper create_table => sub {
  my $self = shift;
  warn "Creating table 'posts'\n";
  $self->db->do('CREATE TABLE posts (title varchar(255), body varchar(255), author varchar(255));');
};

helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM posts') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($title, $body, $author) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO posts VALUES (?,?,?)') } || return undef;
  $sth->execute($title, $body, $author);
  return 1;
};

helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM users') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper insert => sub {
  my $self = shift;
  my ($name, $password) = @_;
  my $sth = eval { $self->db->prepare('INSERT INTO users VALUES (?,?)') } || return undef;
  $sth->execute($name, $password);
  return 1;
};

# if statement didn't prepare, assume its because the table doesn't exist
app->select || app->create_table;

any '/login' => sub {
  my $self = shift;
  my $rows = $self->select;
  $self->stash( rows => $rows );
  $self->render('login/login');
};

# setup base routes
any '/posts' => sub {
  my $self = shift;
  my $rows = $self->select;
  $self->stash( rows => $rows );
  $self->render('main/index');
};

any '/insert' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $password = $self->param('password');
  my $insert = $self->insert($name, $password);
  $self->redirect_to('/');
};

# setup route which receives data and returns to /
any '/insert' => sub {
  my $self = shift;
  my $title = $self->param('title');
  my $body = $self->param('body');
  my $author = $self->param('author');
  my $insert = $self->insert($title, $body, $author);
  $self->redirect_to('login/login');
};

app->start;
