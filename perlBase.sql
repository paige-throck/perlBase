-- 1 up
PRAGMA foreign_keys = ON;


CREATE TABLE users (
  id integer primary key autoincrement,
  name text not null,
  username text not null unique,
  password text not null,
);




create table items (
  id integer primary key autoincrement,
  user_id integer not null,
  foreign key(user_id) references users(id),
  item text,
  completed integer not null default 0,

);

create table movers (
  id integer primary key autoincrement,
  company text,
  website text,
  phone_num text

);

create table moving_day (
  user_id integer not null,
  foreign key(user_id) references users(id),
  mover_id integer not null,
  foreign key(mover_id) references movers(id),
  moving_date text,
  new_address text
);

-- 1 down

PRAGMA foreign_keys = OFF;
drop table if exists users;
drop table if exists items;
drop table if exists movers;
drop table if exists moving_day;
