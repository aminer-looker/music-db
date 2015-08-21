drop database music;
create database music character set = 'UTF8';
use 'music';

create table instruments (
	id integer primary key auto_increment,
	name varchar(255) not null
) engine = InnoDB;

alter table instruments add constraint unique index (name);

create table types (
	id integer primary key auto_increment,
	name varchar(255) not null
) engine = InnoDB;

alter table types add constraint unique index (name);

create table composers (
	id integer primary key auto_increment,
	first_name varchar(255) not null,
	last_name varchar(255) not null,
	url text not null
) engine = InnoDB;

alter table composers add constraint unique_full_name unique index (last_name, first_name);

create table collections (
	id integer primary key auto_increment,
	title text not null,
	url text not null,
    
	composer_id integer not null
) engine = InnoDB;

alter table collections add constraint foreign key (composer_id) references composers (id);

create table works (
	id integer primary key auto_increment,
	title text not null,
    catalog_name varchar(255),
	opus text,
	opus_num text,
	composed_year integer,
	difficulty float,
    key_area varchar(255),
    url text not null,
    
	composer_id integer not null,
	type_id integer,
	instrument_id integer,
    collection_id integer
) engine = InnoDB;

alter table works add constraint foreign key (collection_id) references collections (id);
alter table works add constraint foreign key (composer_id) references composers (id);
alter table works add constraint foreign key (instrument_id) references instruments (id);
alter table works add constraint foreign key (type_id) references types (id);
