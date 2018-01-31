package PerlBase::Model;
use Mojo::Base -base;

use Carp ();

has sqlite => sub { Carp::croak 'sqlite is required' };

sub add_user {
  my ($self, $username) = @_;
  return $self
    ->sqlite
    ->db
    ->insert(
      'users',
      {username => $username},
    )->last_insert_id;
}

sub user {
  my ($self, $username) = @_;
  my $sql = <<'  SQL';
    select
      user.id,
      user.username,
      (
        select
          json_group_array(item)
        from (
          select json_object(
            'id',        items.id,
            'item',     items.item,
            'completed', items.completed
          ) as item
          from items
          where items.user_id=user.id
        )
      ) as items
    from users user
    where user.username=?
  SQL
  return $self
    ->sqlite
    ->db
    ->query($sql, $username)
    ->expand(json => 'items')
    ->hash;
}

# sub list_user_usernames {
#   my $self = shift;
#   return $self
#     ->sqlite
#     ->db
#     ->select(
#       'users' => ['username'],
#       undef,
#       {-asc => 'username'},
#     )
#     ->arrays
#     ->map(sub{ $_->[0] });
# }

sub add_item {
  my ($self, $user, $item) = @_;
  $item->{user_id} = $user->{id};
  return $self
    ->sqlite
    ->db
    ->insert('items' => $item)
    ->last_insert_id;
}

sub update_item {
  my ($self, $item, $selfompleted) = @_;
  return $self
    ->sqlite
    ->db
    ->update(
      'items',
      {completed => $selfompleted},
      {id => $item->{id}},
    )->rows;
}

sub remove_item {
  my ($self, $item) = @_;
  return $self
    ->sqlite
    ->db
    ->delete(
      'items',
      {id => $item->{id}},
    )->rows;
}

1;
