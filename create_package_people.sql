CREATE OR REPLACE PACKAGE people AS 
PROCEDURE cast_director_ins;
PROCEDURE print_cast_director;
end people;
CREATE OR REPLACE PACKAGE BODY people AS
/*ѕроцедура заполн€ет таблицу cast_director_tbl, в которой присутствуют люди, €вл€ющиес€ директорами и актерами, перед заполнением очищает ее*/
 PROCEDURE cast_director_ins
 IS 
CURSOR director_cast IS SELECT c.id_cast, d.id_director, c.name FROM cast c inner join director d on c.name=d.name;
rec director_cast%rowtype;
BEGIN
delete from cast_director_tbl;
commit;
OPEN director_cast;
LOOP
FETCH director_cast INTO rec;
IF director_cast%NOTFOUND
THEN
 DBMS_OUTPUT.PUT_LINE( 'ƒанные не найдены' );
 exit;
else
insert into cast_director_tbl values (rec.id_cast, rec.id_director, rec.name);
commit;
END IF;
END LOOP;
CLOSE director_cast;
END cast_director_ins;

PROCEDURE print_cast_director IS
TYPE cast_movies IS RECORD
(
Name VARCHAR2(200),
Movies_cast VARCHAR2(200)
);
TYPE direc_movies IS RECORD
(
Name VARCHAR2(200),
Movies_direc VARCHAR2(200)
);
TYPE cast_movies_tbl IS TABLE OF cast_movies; cast_movies_rec cast_movies_tbl:= cast_movies_tbl();
TYPE direc_movies_tbl IS TABLE OF direc_movies; direc_movies_rec direc_movies_tbl:= direc_movies_tbl();
BEGIN
SELECT cdt.name,m1.title BULK COLLECT INTO cast_movies_rec
FROM cast_director_tbl cdt inner join cast_movies cm on cdt.id_cast=cm.id_cast
inner join movies m1 on m1.id=cm.id_movies;
SELECT cdt.name,m2.title BULK COLLECT INTO direc_movies_rec
FROM cast_director_tbl cdt 
inner join director_movies dm on cdt.id_director=dm.id_director
inner join movies m2 on m2.id=dm.id_movies;
FOR i IN cast_movies_rec.FIRST..cast_movies_rec.LAST
LOOP
dbms_output.put_line ('Name: '||cast_movies_rec(i).Name); 
dbms_output.put_line ('Movies_cast: '||cast_movies_rec(i).Movies_cast); 
FOR j IN direc_movies_rec.FIRST..direc_movies_rec.LAST
LOOP
if cast_movies_rec(i).Name = direc_movies_rec(j).Name then
dbms_output.put_line ('Movies_director:'|| direc_movies_rec(j).Movies_direc); 
end if;
END LOOP;
dbms_output.put_line('--------------------------------');
END LOOP;
END print_cast_director;

end people;


/*
begin
people.cast_director_ins;
end;
select * from cast_director_tbl*/

/*
begin
people.print_cast_director;
end;
*/
