DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

CREATE TABLE emp( eid integer primary key);

CREATE TABLE area( aid integer primary key);

create table courses (cid integer primary key, aid integer references area);

create table co (cid integer, sess integer, primary key (cid, sess), foreign key (cid) references courses);

create table manage (eid integer references emp, aid integer references area, primary key (aid, eid));

create table mana (eid integer, aid integer, cid integer, sess integer, foreign key (cid, sess) references co, foreign key (aid, eid) references manage, primary key (cid, sess, aid ,eid));

insert into emp (eid) values (100);
insert into emp (eid) values (200);

insert into area (aid) values (10);
insert into area (aid) values (20);


insert into courses (cid, aid) values (2030 , 10);
insert into courses (cid, aid) values (2040 , 20);

insert into co (cid, sess) values (2030 , 1);
insert into co (cid, sess) values (2040 , 2);

insert into manage (aid, eid) values (10, 100);
insert into manage (aid, eid) values (20, 200);

insert into mana (cid, sess, aid ,eid) values (2040, 2, 10,100);
insert into mana (cid, sess, aid ,eid) values (2030, 1, 10,100);
insert into mana (cid, sess, aid ,eid) values (2030, 1, 20,200);