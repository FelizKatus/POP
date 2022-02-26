create table if not exists products (
  id integer primary key autoincrement,
  title string not null,
  text string not null
);
