-- 查找面积超过 3,000,000 或者人口数超过 25,000,000 的国家。
-- DROP TABLE
-- IF
--     EXISTS World;
-- CREATE TABLE World ( NAME VARCHAR ( 255 ), continent VARCHAR ( 255 ), area INT, population INT, gdp INT );
-- INSERT INTO World ( NAME, continent, area, population, gdp )
-- VALUES
--     ( 'Afghanistan', 'Asia', '652230', '25500100', '203430000' ),
--     ( 'Albania', 'Europe', '28748', '2831741', '129600000' ),
--     ( 'Algeria', 'Africa', '2381741', '37100000', '1886810000' ),
--     ( 'Andorra', 'Europe', '468', '78115', '37120000' ),
--     ( 'Angola', 'Africa', '1246700', '20609294', '1009900000' );
-- 方法一
SELECT name,
    population,
    area
FROM
    World
WHERE
    area > 3000000
    OR population > 25000000;
		
-- 方法二
SELECT name,
    population,
    area
FROM
    World
WHERE
    area > 3000000
SELECT name,
    population,
    area
FROM
    World
WHERE
		population > 25000000;



-- 只用一个 SQL 查询，将 sex 字段反转。
-- DROP TABLE
-- IF
--     EXISTS salary;
-- CREATE TABLE salary ( id INT, NAME VARCHAR ( 100 ), sex CHAR ( 1 ), salary INT );
-- INSERT INTO salary ( id, NAME, sex, salary )
-- VALUES
--     ( '1', 'A', 'm', '2500' ),
--     ( '2', 'B', 'f', '1500' ),
--     ( '3', 'C', 'm', '5500' ),
--     ( '4', 'D', 'f', '500' );
-- 方法一
update salary set sex = (case sex when 'f' then 'm' else 'f' END)
-- 方法二
UPDATE salary
SET sex = CHAR ( ASCII(sex) ^ ASCII( 'm' ) ^ ASCII( 'f' ) );


-- 查找 id 为奇数，并且 description 不是 boring 的电影，按 rating 降序。
-- DROP TABLE
-- IF
--     EXISTS cinema;
-- CREATE TABLE cinema ( id INT, movie VARCHAR ( 255 ), description VARCHAR ( 255 ), rating FLOAT ( 2, 1 ) );
-- INSERT INTO cinema ( id, movie, description, rating )
-- VALUES
--     ( 1, 'War', 'great 3D', 8.9 ),
--     ( 2, 'Science', 'fiction', 8.5 ),
--     ( 3, 'irish', 'boring', 6.2 ),
--     ( 4, 'Ice song', 'Fantacy', 8.6 ),
--     ( 5, 'House card', 'Interesting', 9.1 );
select * from cinema where id%2 =1 and description not like '%boring%' order by rating desc

-- 查找有五名及以上 student 的 class。
-- DROP TABLE
-- IF
--     EXISTS courses;
-- CREATE TABLE courses ( student VARCHAR ( 255 ), class VARCHAR ( 255 ) );
-- INSERT INTO courses ( student, class )
-- VALUES
--     ( 'A', 'Math' ),
--     ( 'B', 'English' ),
--     ( 'C', 'Math' ),
--     ( 'D', 'Biology' ),
--     ( 'E', 'Math' ),
--     ( 'F', 'Computer' ),
--     ( 'G', 'Math' ),
--     ( 'H', 'Math' ),
--     ( 'I', 'Math' );

select class from courses group by class having count(student)>5



-- 查找重复的邮件地址
-- DROP TABLE
-- IF
--     EXISTS Person;
-- CREATE TABLE Person ( Id INT, Email VARCHAR ( 255 ) );
-- INSERT INTO Person ( Id, Email )
-- VALUES
--     ( 1, 'a@b.com' ),
--     ( 2, 'c@d.com' ),
--     ( 3, 'a@b.com' );
select email from person group by email having count(email) >1


-- 删除重复的邮件地址：
