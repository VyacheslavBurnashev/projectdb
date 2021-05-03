create table type (type_id number,
type varchar2(20) not null,
constraint pk_type_id PRIMARY KEY(type_id));

Create sequence type_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_type_id
    before insert on type
     for each row
   begin
     select type_sequence.nextval
      into :new.type_id
       from dual;
    end;

insert into type (type)
select distinct type from netflix_csv;*/

--2
/*создание таблицы Директора*/
create table director (id_director number,
Name varchar2(200) not null,
constraint pk_id_director PRIMARY KEY(id_director));

Create sequence director_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_director
    before insert on director
     for each row
   begin
     select director_sequence.nextval
      into :new.id_director
       from dual;
    end;



insert into director (name)
with t as (select director from netflix_csv where director is not null union all select director from netflix_csv where director is not null),
    tt as (select rownum as rn, director from t)
select distinct regexp_substr(director, '[^,]+', 1, level) director
  from tt
  connect by regexp_substr(director, '[^,]+', 1, level) is not null
         and rn = prior rn
         and prior dbms_random.value is not null;
         
       
update director
set name=ltrim(name);

delete from director where id_director in (
select min(id_director)
from director t1
where exists (
select *
from director t2
where ( (t1.name = t2.name) and (t1.id_director != t2.id_director) )
) group by name);

--3
/*создание таблицы Актеры*/
create table cast (id_cast number,
Name varchar2(200) not null,
constraint pk_id_cast PRIMARY KEY(id_cast));

Create sequence cast_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_cast
    before insert on cast
     for each row
   begin
     select cast_sequence.nextval
      into :new.id_cast
       from dual;
    end;



insert into cast (name)
with t as (select cast from netflix_csv where cast is not null union all select cast from netflix_csv where cast is not null),
    tt as (select rownum as rn, cast from t)
select distinct regexp_substr(cast, '[^,]+', 1, level) cast
  from tt
  connect by regexp_substr(cast, '[^,]+', 1, level) is not null
         and rn = prior rn
         and prior dbms_random.value is not null;
         
       
update cast
set name=ltrim(name);

delete from cast where id_cast in (
select min(id_cast)
from cast t1
where exists (
select *
from cast t2
where ( (t1.name = t2.name) and (t1.id_cast != t2.id_cast) )
) group by name);

--4
/*создание таблицы Страны*/
create table country (id_country number,
country varchar2(200) not null,
constraint pk_id_country PRIMARY KEY(id_country));

Create sequence country_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_country
    before insert on country
     for each row
   begin
     select country_sequence.nextval
      into :new.id_country
       from dual;
    end;



insert into country (country)
with t as (select country from netflix_csv where country is not null union all select country from netflix_csv where country is not null),
    tt as (select rownum as rn, country from t)
select distinct regexp_substr(country, '[^,]+', 1, level) country
  from tt
  connect by regexp_substr(country, '[^,]+', 1, level) is not null
         and rn = prior rn
         and prior dbms_random.value is not null;
         
       
update country
set country=ltrim(country);

delete from country where id_country in (
select min(id_country)
from country t1
where exists (
select *
from country t2
where ( (t1.country = t2.country) and (t1.id_country != t2.id_country) )
) group by country);

--5
/*создание таблицы Рейтинг MPAA*/
create table rating (id_rating number,
rating varchar2(100) not null,
constraint pk_id_rating PRIMARY KEY(id_rating));

Create sequence rating_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_rating
    before insert on rating
     for each row
   begin
     select rating_sequence.nextval
      into :new.id_rating
       from dual;
    end;

insert into rating (rating)
select distinct rating from netflix_csv where rating is not null;


--6
/*создание таблицы Список*/
create table list (id_list number,
list varchar2(100) not null,
constraint pk_id_list PRIMARY KEY(id_list));

Create sequence list_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_list
    before insert on list
     for each row
   begin
     select list_sequence.nextval
      into :new.id_list
       from dual;
    end;

insert into list (list)
with t as (select listed_in from netflix_csv where listed_in is not null union all select listed_in from netflix_csv where listed_in is not null),
    tt as (select rownum as rn, listed_in from t)
select distinct regexp_substr(listed_in, '[^,]+', 1, level) listed_in
  from tt
  connect by regexp_substr(listed_in, '[^,]+', 1, level) is not null
         and rn = prior rn
         and prior dbms_random.value is not null;
         
       
update list
set list=ltrim(list);

delete from list where id_list in (
select min(id_list)
from list t1
where exists (
select *
from list t2
where ( (t1.list = t2.list) and (t1.id_list != t2.id_list) )
) group by list);




--7

create table movies (id number,
show_id varchar2(10),
type_id number,
title varchar2(1000),
date_added varchar2(100),
release_year number,
id_rating number,
duration varchar2(100),
description varchar2(4000),
picture blob,
constraint pk_id_movies PRIMARY KEY(id),
CONSTRAINT fk_type
    FOREIGN KEY (type_id)
    REFERENCES type(type_id),
CONSTRAINT fk_rating
    FOREIGN KEY (id_rating)
    REFERENCES rating(id_rating));

Create sequence movies_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_movies
    before insert on movies
     for each row
   begin
     select movies_sequence.nextval
      into :new.id
       from dual;
    end;
    
    /*создание триггера на проверку корректности заполнения поля release_year*/
create trigger trg_release_year_movies
    before insert or update on movies
     for each row
   begin
   if not (preobraz.check_year(:NEW.release_year))
   then raise_application_error(-20001, 'Incorrect, type yyyy');
   end if;
    end;

/Заполнение таблицы из данных csv (предварительно загружены в таблицу netflix_csv)    
insert into movies (show_id,type_id,title,date_added,release_year,id_rating, duration,description)
select show_id,
(select type_id from type where type=ns.type),
title,
date_added,
release_year,
(select id_rating from rating where rating=ns.rating),
duration,
description
from netflix_csv ns;    

*/

--8
/*создание таблицы Актеры-фильмы*/
create table cast_movies (id number,
id_cast number,
id_movies number,
constraint pk_id_cm PRIMARY KEY(id),
CONSTRAINT fk_cast
    FOREIGN KEY (id_cast)
    REFERENCES cast(id_cast),
  CONSTRAINT fk_movies
    FOREIGN KEY (id_movies)
    REFERENCES movies(id));

Create sequence cast_movies_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_cast_movies
    before insert on cast_movies
     for each row
   begin
     select cast_movies_sequence.nextval
      into :new.id
       from dual;
    end;
Заполнение таблицы из данных csv (предварительно загружены в таблицу netflix_csv)
*/

--9
/*создание таблицы Директор-фильмы*/
create table director_movies (id number,
id_director number,
id_movies number,
constraint pk_id_dm PRIMARY KEY(id),
CONSTRAINT fk_director
    FOREIGN KEY (id_director)
    REFERENCES director(id_director),
  CONSTRAINT fk_movies_dir
    FOREIGN KEY (id_movies)
    REFERENCES movies(id));

Create sequence director_movies_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_director_movies
    before insert on director_movies
     for each row
   begin
     select director_movies_sequence.nextval
      into :new.id
       from dual;
    end;*Заполнение таблицы из данных csv (предварительно загружены в таблицу netflix_csv)
insert into director_movies (id_director,id_movies)
select d.id_director,m.id from director d 
,netflix_csv ns,movies m where ns.show_id=m.show_id and ns.director like '%' || d.name || '%';*/

--10
/*создание таблицы Страна-фильмы*/
create table country_movies (id number,
id_country number,
id_movies number,
constraint pk_id_countrym PRIMARY KEY(id),
CONSTRAINT fk_country
    FOREIGN KEY (id_country)
    REFERENCES country(id_country),
  CONSTRAINT fk_movies_coun
    FOREIGN KEY (id_movies)
    REFERENCES movies(id));

Create sequence country_movies_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_country_movies
    before insert on country_movies
     for each row
   begin
     select country_movies_sequence.nextval
      into :new.id
       from dual;
    end;
Заполнение таблицы из данных csv (предварительно загружены в таблицу netflix_csv)
insert into country_movies (id_country,id_movies)
select c.id_country,m.id from country c 
,netflix_csv ns,movies m where ns.show_id=m.show_id and ns.country like '%' || c.country || '%';*/
         
       
--11
/*создание таблицы Списки-фильмы*/
create table list_movies (id number,
id_list number,
id_movies number,
constraint pk_id_lm PRIMARY KEY(id),
CONSTRAINT fk_list
    FOREIGN KEY (id_list)
    REFERENCES list(id_list),
  CONSTRAINT fk_movies_list
    FOREIGN KEY (id_movies)
    REFERENCES movies(id));

Create sequence list_movies_sequence;
/*создание триггера на автоматическое заполнение id*/
create trigger trg_id_list_movies
    before insert on list_movies
     for each row
   begin
     select list_movies_sequence.nextval
      into :new.id
       from dual;
    end;
Заполнение таблицы из данных csv (предварительно загружены в таблицу netflix_csv)
insert into list_movies (id_list,id_movies)
select l.id_list,m.id from list l 
,netflix_csv ns,movies m where ns.show_id=m.show_id and ns.listed_in = l.list;

insert into list_movies (id_list,id_movies)
select l.id_list,m.id from list l 
,netflix_csv ns,movies m where ns.show_id=m.show_id and ns.listed_in like '%' ||', ' || l.list || '%';

insert into list_movies (id_list,id_movies)
select l.id_list,m.id from list l 
,netflix_csv ns,movies m where ns.show_id=m.show_id and ns.listed_in like  l.list || ',' || '%';

truncate table list_movies
*/

--12 создание таблицы для хранения информации о том, какие люди являются директорами и актерами в фильмах, заполняем процедурой cast_director_ins

create table cast_director_tbl (id_cast number,
id_director number,
name varchar2(200));

