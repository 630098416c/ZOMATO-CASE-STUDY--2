create database case_study ;
use case_study ;
drop  table if exists sales ;
create table sales(user_id int ,created_date date ,product_id int );
insert into sales(user_id  ,created_date ,product_id )
VALUES 
(1, '2017-04-19', 2),
(3, '2019-12-18', 1),
(2, '2020-07-20', 3),
(1, '2019-10-23', 2),
(1, '2018-03-19', 3),
(3, '2016-12-20', 2),
(1, '2016-11-09', 1),
(1, '2016-05-20', 3),
(2, '2017-09-24', 1),
(1, '2017-03-11', 2),
(1, '2016-03-11', 1),
(3, '2016-11-10', 1),
(3, '2017-12-07', 2),
(3, '2016-12-15', 2),
(2, '2017-11-08', 2),
(2, '2018-09-10', 3);
select*
from sales;
drop TABLE IF exists GOLD_USERS_SIGNUP;
CREATE TABLE GOLD_USERS_SIGNUP(USER_ID INT ,GOLD_SIGN_DATE DATE );
insert into GOLD_USERS_SIGNUP(USER_ID,GOLD_SIGN_DATE)
VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');
select * 
from GOLD_USERS_SIGNUP;

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from GOLD_USERS_SIGNUP ;
select * from users;


-- Problem 1 : What is the total amount each customer spent on zomato?
SELECT  S.USER_ID,SUM(P.PRICE) AS MONEY_SPENT
FROM SALES S
INNER JOIN PRODUCT P ON
S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY USER_ID
ORDER BY USER_ID;

-- Problem 2: How many days has each customer visited zomato?
SELECT USER_ID ,COUNT(DISTINCT CREATED_DATE) AS NO_OF_DAYS_VISIT_ZOMATO
FROM SALES 
GROUP BY USER_ID ;

 -- Problem 3: What was the first product purchased by each customer?
 
select s.USER_ID,s.created_date,p.product_id,p.product_name,p.price, row_number() over(partition by USER_ID order by created_date) as rn
from sales s
inner join product p on s.product_id = S.product_id;
with cte as(
select s.USER_ID,s.created_date,p.product_id,p.product_name,p.price, row_number() over(partition by USER_Id order by created_date) as rn
from sales s
inner join product p on s.product_id = p.product_id  
)
select * from cte
where rn =1;

-- Problem 4: What is the most purchased item on the menu and how many times it was purchased by all the customers?
select product_id
from sales
group by product_id
order by count(product_id)desc 
limit 1;


select USER_ID,count(product_id) as order_count from sales
where product_id = (
select product_id
from sales
group by product_id
order by count(product_id) desc
limit 1
)
group by USER_ID
order by USER_ID;

-- Problem 5: Which item is popular for each customer?
select user_id ,product_id,count(product_id) as cnt 
from sales 
group by user_id,product_id
order by user_id;
with cte as(
select user_id,product_id,count(product_id) as cnt
from sales
group by user_id,product_id
order by user_id)
select *, rank()over(partition by user_id order by cnt desc) as rnk
from cte;

with cte as(
select user_id,product_id,count(product_id) as cnt
from sales
group by user_id,product_id
order by user_id),
cte2 as(
select *, rank()over(partition by user_id order by cnt desc) as rnk
from cte)
select * from cte2
where rnk =1;

-- Problem 6: Which item was first purchased by the customer once they became the member?

-- Query 1
SELECT s.user_id, s.product_id, g.GOLD_SIGN_DATE, s.created_date, 
       DATEDIFF(s.created_date, g.GOLD_SIGN_DATE) AS dd
FROM sales s 
INNER JOIN users u ON s.user_id = u.userid 
LEFT JOIN GOLD_USERS_SIGNUP g ON s.user_id = g.user_id  
ORDER BY s.user_id, dd;

-- Query 2
SELECT s.user_id, s.product_id, g.GOLD_SIGN_DATE, s.created_date, 
       DATEDIFF(s.created_date, g.GOLD_SIGN_DATE) AS dd
FROM sales s 
INNER JOIN users u ON s.user_id = u.userid 
LEFT JOIN GOLD_USERS_SIGNUP g ON s.user_id = g.user_id 
WHERE DATEDIFF(s.created_date, g.GOLD_SIGN_DATE) > 0  
ORDER BY s.user_id, dd;

-- Query 3
WITH cte AS (
    SELECT s.user_id, s.product_id, g.GOLD_SIGN_DATE, s.created_date, 
           DATEDIFF(s.created_date, g.GOLD_SIGN_DATE) AS dd
    FROM sales s 
    INNER JOIN users u ON s.user_id = u.userid 
    LEFT JOIN GOLD_USERS_SIGNUP g ON s.user_id = g.user_id 
    WHERE DATEDIFF(s.created_date, g.GOLD_SIGN_DATE) > 0  
    ORDER BY s.user_id, dd
)
SELECT *, RANK() OVER (PARTITION BY user_id ORDER BY dd) AS rnk
FROM cte;

-- Query 4
WITH cte AS (
    SELECT s.user_id, s.product_id, g.GOLD_SIGN_DATE, s.created_date, 
           DATEDIFF(s.created_date, g.GOLD_SIGN_DATE) AS dd
    FROM sales s 
    INNER JOIN users u ON s.user_id = u.userid 
    LEFT JOIN GOLD_USERS_SIGNUP g ON s.user_id = g.user_id 
    WHERE DATEDIFF(s.created_date, g.GOLD_SIGN_DATE) > 0  
    ORDER BY s.user_id, dd
), cte2 AS (
    SELECT *, RANK() OVER (PARTITION BY user_id ORDER BY dd) AS rnk
    FROM cte
)
SELECT *
FROM cte2 
WHERE rnk = 1;
