CREATE OR REPLACE PACKAGE audit_movies AS 
PROCEDURE auditoriya ( age_in IN varchar2 );
end audit_movies;

CREATE OR REPLACE PACKAGE BODY audit_movies AS
 PROCEDURE auditoriya
  ( age_in IN varchar2 )
 IS 
CURSOR age_movies IS SELECT m.title, r.rating, case  when  r.rating in ('NC-17','TV-MA') then 'Only for adults' 
when r.rating in ('PG','TV-Y7','TV-Y','TV-PG','TV-G','G','TV-Y7-FV')
then 'For everyone who older than 7 year'
when r.rating in ('TV-14','R','PG-13','UR','NR')
then 'Watch only with parents'
end as age  FROM movies m inner join rating r on r.id_rating=m.id_rating;
rec age_movies%rowtype;
nCount NUMBER;
nCount1 NUMBER;
v_sql LONG;
v_sql1 LONG;
TYPE age_movies_collection IS RECORD
(
title varchar2(200), 
rating varchar2(100),
Rating_description varchar2(200), 
age varchar2(200)
);
TYPE age_movies_tbl IS TABLE OF age_movies_collection; age_movies_rec age_movies_tbl:= age_movies_tbl();
begin
SELECT count(*) into nCount FROM user_tables where table_name = 'AGE_MOVIES';
IF(nCount <= 0)
THEN
v_sql:='
create table AGE_MOVIES
(
title varchar2(500),
rating VARCHAR2(30),
rating_description varchar2(200),
age varchar2(200)
)';
execute immediate v_sql;
END IF;
SELECT count(*) into nCount1 FROM AGE_MOVIES;
IF(nCount1 > 0)
THEN
v_sql1:='delete from AGE_MOVIES';
execute immediate v_sql1;
END IF;
OPEN age_movies;
LOOP
FETCH age_movies INTO rec;
IF age_movies%NOTFOUND
THEN
 DBMS_OUTPUT.PUT_LINE( 'Data is not found' );
 exit;
else
insert into age_movies values (rec.title, rec.rating,preobraz.Rating_description(rec.rating), rec.age);
commit;
END IF;
END LOOP;
CLOSE age_movies;
SELECT * BULK COLLECT INTO age_movies_rec
FROM age_movies am where am.age=age_in;
FOR i IN age_movies_rec.FIRST..age_movies_rec.LAST
LOOP
dbms_output.put_line ('title: '||age_movies_rec(i).title); 
dbms_output.put_line ('rating: '||age_movies_rec(i).rating); 
dbms_output.put_line ('rating_description: '||age_movies_rec(i).rating_description); 
dbms_output.put_line ('age: '||age_movies_rec(i).age); 
dbms_output.put_line('--------------------------------');
END LOOP;
END auditoriya;
end audit_movies;


begin
audit_movies.auditoriya('Only for adults');
end;