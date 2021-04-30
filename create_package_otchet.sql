CREATE OR REPLACE PACKAGE otchet AS 
PROCEDURE listed ( list_find IN varchar2 );
end otchet;
CREATE OR REPLACE PACKAGE BODY otchet AS
 PROCEDURE listed
  ( list_find IN varchar2 )
 IS 
CURSOR listed_movies IS SELECT m.title,case when m.duration like '%min%' then Preobraz.Min_in_hour(m.duration) else m.duration end as duration, l.list FROM movies m inner join list_movies lm on m.id=lm.id_movies inner join list l on l.id_list=lm.id_list where l.list=list_find;
rec listed_movies%rowtype;
nCount NUMBER;
nCount1 NUMBER;
v_sql LONG;
v_sql1 LONG;
begin
SELECT count(*) into nCount FROM user_tables where table_name = 'LISTED_OTCHET';
IF(nCount <= 0)
THEN
v_sql:='
create table listed_otchet
(
title varchar2(500),
duration VARCHAR2(30),
list varchar2(200)
)';
execute immediate v_sql;
END IF;
SELECT count(*) into nCount1 FROM LISTED_OTCHET;
IF(nCount1 > 0)
THEN
v_sql1:='delete from listed_otchet';
execute immediate v_sql1;
END IF;
OPEN listed_movies;
LOOP
FETCH listed_movies INTO rec;
IF listed_movies%NOTFOUND
THEN
 DBMS_OUTPUT.PUT_LINE( 'Данные не найдены' );
 exit;
else
insert into listed_otchet values (rec.title, rec.duration, rec.list);
commit;
END IF;
END LOOP;
CLOSE listed_movies;
END listed;
end otchet;
/*
begin
otchet.listed('Classic Movies');
end;*/


