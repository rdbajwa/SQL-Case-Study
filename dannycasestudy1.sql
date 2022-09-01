USE [DannyCaseStudy1]
GO

/****** Object:  Schema [dannys_diner]    Script Date: 29-08-2022 13:31:40 ******/
CREATE SCHEMA [dannys_diner]
GO



CREATE TABLE dannys_diner.sale (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);


INSERT INTO dannys_diner.sale
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
select * from members

 CREATE TABLE dannys_diner.menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO dannys_diner.menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE dannys_diner.members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO dannys_diner.members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


 --- What is the total amount each customer spent at the restaurant?

 select customer_id, sum(price) as total_money_spent
 from
 (select s.*, m.product_name, m.price
 from dannys_diner.sales as s
 join dannys_diner.menu as m
 on s.product_id=m.product_id) as t
 group by customer_id

 --result shows customer_id 'A' has spend maximum

 --How many days has each customer visited the restaurant?

 select customer_id, count(order_date) as total_num_of_days
 from dannys_diner.sales
 group by customer_id


 --What was the first item from the menu purchased by each customer?
 select r.*,m.product_name from
 (
 select row_number()over(partition by customer_id order by order_date) as first_Day, customer_id, order_date, product_id
 from DannyCaseStudy1.dannys_diner.sales as s) r
 inner join DannyCaseStudy1.dannys_diner.menu m
 on r.product_id=m.product_id
  where first_Day=1


 -- What is the most purchased item on the menu and how many times was it purchased by all customers?

 select  Top 1 count(s.product_id) as  most_purchased, m.product_name
 from DannyCaseStudy1.dannys_diner.sales as s
 join DannyCaseStudy1.dannys_diner.menu as m
 on s.product_id=m.product_id
 group by s.product_id, product_name
 order by count(s.product_id) desc

 --and how many times was it purchased by all customers?
 select Top 1 count(s.order_date) as total_orders, m.product_name
 from DannyCaseStudy1.dannys_diner.sales s
 join DannyCaseStudy1.dannys_diner.menu m
 on s.product_id=m.product_id
 group by s.product_id,m.product_name
 order by total_orders desc
 

 ---Which item was the most popular for each customer?

 select *
 from
 (
 select r.*, m.product_name , DENSE_RANK() over(partition by r.customer_id order by total_purchased desc) as rank1  from
 (
 select s.customer_id, count(s.product_id) as total_purchased, product_id
 from DannyCaseStudy1.dannys_diner.sales s
 group by customer_id, product_id) r
 join DannyCaseStudy1.dannys_diner.menu m
 on r.product_id=m.product_id) t
 where rank1=1

 --Which item was purchased first by the customer after they became a member?

 select r.* , m2.product_name from
 (select row_number()over(partition by s.customer_id order by order_date) as row_num ,s.customer_id, s.product_id,s.order_date, m.join_datefrom DannyCaseStudy1.dannys_diner.sales s
 join DannyCaseStudy1.dannys_diner.members m
 on s.customer_id=m.customer_id
 where s.order_date>=m.join_date) r
 join DannyCaseStudy1.dannys_diner.menu m2
 on r.product_id=m2.product_id
 where row_num=1

 --Which item was purchased just before the customer became a member?
  select r.* , m2.product_name from
 (select rank()over(partition by s.customer_id order by order_date desc) as rank_num ,s.customer_id, s.product_id,s.order_date, m.join_date
 from DannyCaseStudy1.dannys_diner.sales s
 join DannyCaseStudy1.dannys_diner.members m
 on s.customer_id=m.customer_id
 where s.order_date < m.join_date) r
 join DannyCaseStudy1.dannys_diner.menu m2
 on r.product_id=m2.product_id
 where rank_num=1 
 --What is the total items and amount spent for each member before they became a member?

 select s.customer_id, count(s.order_date) as total_items, sum(m.price) as total_amount
 from DannyCaseStudy1.dannys_diner.sales s
 join DannyCaseStudy1.dannys_diner.menu m
 on s.product_id=m.product_id
 join DannyCaseStudy1.dannys_diner.members m2
 on s.customer_id=m2.customer_id
 where s.order_date < m2.join_date
 group by s.customer_id



 --If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id, 
sum
(
case when s.product_id=1 then price*20
else price*10
end
) as total_points
from DannyCaseStudy1.dannys_diner.sales s
join DannyCaseStudy1.dannys_diner.menu m
on s.product_id=m.product_id
group by s.customer_id

/*
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January?
*/
select s.customer_id, 
sum
(
case when s.order_date >= m2.join_date and  s.order_date <=dateadd(day,6,m2.join_date) then m.price*20
else
( case when s.product_id=1 then m.price*20 
else m.price*10
end
)end) as total_points
from DannyCaseStudy1.dannys_diner.sales s
join DannyCaseStudy1.dannys_diner.menu m
on s.product_id=m.product_id
join DannyCaseStudy1.dannys_diner.members m2
on s.customer_id=m2.customer_id
where s.order_date between '2021-01-01' and '2021-01-31'
group by s.customer_id




--Joining all tables
select s.customer_id, s.order_date, m.product_name,
 m.price, 
(case when s.order_date>=m2.join_date then 'Y'
else 'N'
end)as members
from DannyCaseStudy1.dannys_diner.sales s
join DannyCaseStudy1.dannys_diner.menu m
on s.product_id=m.product_id
left join DannyCaseStudy1.dannys_diner.members m2
on s.customer_id=m2.customer_id

--ranking all things in table
with ranking_table as
(
select s.customer_id, s.order_date, m.product_name,
 m.price, 
(case when s.order_date>=m2.join_date then 'Y'
else 'N'
end)as members
from DannyCaseStudy1.dannys_diner.sales s
join DannyCaseStudy1.dannys_diner.menu m
on s.product_id=m.product_id
left join DannyCaseStudy1.dannys_diner.members m2
on s.customer_id=m2.customer_id
)
Select *, Case
when members='N' then null
else
 dense_rank()over(partition by customer_id,members order by order_date) end as ranking
 from ranking_table








