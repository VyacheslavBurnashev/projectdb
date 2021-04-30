CREATE OR REPLACE PACKAGE preobraz AS 
Function Min_in_hour ( duration IN varchar2 )
   RETURN varchar2;
Function Rating_description (rating IN varchar2)
 RETURN varchar2;
Function check_year
   ( release_year IN NUMBER )
   RETURN BOOLEAN;
end preobraz;

CREATE OR REPLACE PACKAGE BODY preobraz AS
 Function Min_in_hour
   ( duration IN varchar2 )
   RETURN varchar2
IS
result varchar2(200);
begin
select  to_char(floor(to_number(replace(duration,' min',''))/60)) || 'h ' || to_char(mod(to_number(replace(duration,' min','')),60))  || 'min' into result
from dual;
return result;
END;

Function Rating_description
(rating IN varchar2)
 RETURN varchar2
 IS
 result varchar2(200);
begin
case when rating='TV-14'
then return 'Тип программ, содержащей материалы, не подходящие для детей в возрасте до 14 лет';
when rating='R'
then return 'Лицам до 17 лет обязательно присутствие взрослого';
when rating='NC-17'
then return 'Лицам до 18 лет просмотр запрещен';
when rating='TV-MA'
then return 'Тип программ, предназначенный для взрослых людей и не рекомендуется детям до 17 лет';
when rating='PG-13'
then return 'Детям до 13 лет просмотр не желателен';
when rating='UR'
then return ' ';
when rating='PG'
then return 'Рекомендуется присутствие родителей';
when rating='TV-Y7'
then return 'Тип программ, предназначенный для детей от 7 лет и старше';
when rating='NR'
then return ' ';
when rating='TV-Y'
then return 'Тип программ, предназначенный для детей любого возраста';
when rating='TV-PG'
then return 'Тип программ, содержащий материалы, которые родители могут счесть не подходящими для маленьких детей';
when rating='TV-G'
then return 'Большинство родителей сочтут этот класс программ подходящим для любого возраста';
when rating='G'
then return 'Нет возрастных ограничений';
when rating='TV-Y7-FV'
then return 'Тип программ, предназначенный для детей от 7 лет и старше,наличие вымышленного насилия';
end case;
end; 

Function check_year
   ( release_year IN NUMBER )
   RETURN BOOLEAN
IS
result BOOLEAN;
begin
if length(to_char(release_year ))<>4
then result:=false;
else
result:=true;
end if;
return result;
END;

end Preobraz;


