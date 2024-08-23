create database pizzahut;
use pizzahut;
select * from pizzas;
select * from pizza_types;
-- create table orders (
-- order_id int not null ,
-- order_date date not null,
-- order_time time not null,
-- primary key(order_id));

-- create table order_details(
-- order_details_id int not null,
-- order_id int not null,
-- pizza_id text not null,
-- quantity int not null,
-- primary key(order_details_id));
select * from orders;

select * from order_details;


-- 1. Retrieve the total number of orders placed.
select count(*) as total_order from orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM((od.quantity * p.price)), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id;
    
-- 3. Identify the highest-priced pizza.
SELECT 
    pt.name, MAX(p.price) AS highest_price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id;

-- 4. Identify the most common pizza size ordered.
select p.size, count(od.order_details_id) as order_count
from pizzas p 
join order_details od
on p.pizza_id = od.pizza_id
group by p.size
order by order_count desc;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS quantities
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY quantities DESC
LIMIT 5;

-- Intermediate:
-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(o.order_time) AS hour, COUNT(o.order_id) AS order_cnt
FROM
    orders o
GROUP BY hour
ORDER BY hour;

-- 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pt.category, COUNT(pt.name) 
FROM
    pizza_types pt
GROUP BY pt.category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_order_per_day
FROM
    (SELECT 
        order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY order_date) AS ord_quantity;

-- 10. Determine the top 3 most ordered pizza types based on revenue.
select pt.name, sum(p.price * od.quantity) as revenue from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.name
order by revenue desc limit 3;

-- Advanced:
-- 11.Calculate the percentage contribution of each pizza type to total revenue.
with cte as (
select pt.category , sum(p.price * od.quantity) as revenue from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id 
join order_details od on od.pizza_id = p.pizza_id
group by pt.category order by revenue desc)

select category, round((revenue/total_revenue) * 100,2) as percentage_contribution from
 (select category , revenue, sum(revenue) over() as total_revenue from cte
group by category)as percentage_revenue; 

-- 12.Analyze the cumulative revenue generated over time.
with cte as(
select o.order_date, sum(p.price* od.quantity) as revenue 
from orders o join order_details od on od.order_id = o.order_id
join pizzas p on p.pizza_id = od.pizza_id
group by order_date)

select order_date, round(sum(revenue) over(order by order_date),2)as cumulative_revenue from cte;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as(
select pt.name, pt.category, sum(p.price * od.quantity) as revenue_of_each_pizza_type from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.name
order by revenue_of_each_pizza_type)

select name, category, revenue_of_each_pizza_type ,ranking from (
select name, category,revenue_of_each_pizza_type,
rank() over(partition by category order by revenue_of_each_pizza_type desc)as ranking from cte)
as revenue_table 
where ranking <=3;