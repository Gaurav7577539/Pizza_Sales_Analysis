-- Retrieve the total number of orders placed.
select count(order_id) from orders;

-- Calculate the total revenue generated from pizza sales.
Select round(sum(order_details.quantity*pizzas.price)) from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name, max(pizzas.price) as Max_Price from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name order by Max_Price desc;

-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as Max_Count from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size order by Max_Count desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, count(order_details.quantity) as Max_Count from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id group by pizza_types.name, order_details.quantity order by Max_Count Desc limit 5;

-- find the total quantity of each pizza category ordered.
Select pizza_types.category, count(order_details.quantity) as Total_Quantity from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id group by pizza_types.category order by Total_Quantity Desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) as Orders_Distribution from orders group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select pizza_types.category, count(pizzas.pizza_id) as Pizza_Distributions from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select day(orders.order_date) as orde_day, count(pizzas.pizza_id) as total_pizzas from orders
join order_details on order_details.order_id = orders.order_id 
join pizzas on order_details.pizza_id = pizzas.pizza_id
group by day(orders.order_date) order by day(orders.order_date);

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name as pizza_type, round(sum(order_details.quantity*pizzas.price)) As Total_Revenue from order_details
join orders on order_details.order_id = orders.order_id
join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_type order by Total_Revenue Desc Limit 3;

-- Calculate percentage contribution of each pizza type to total revenue
WITH category_revenue AS (
    SELECT pizza_types.category AS pizza_type, SUM(order_details.quantity * pizzas.price) AS total_revenue
    FROM order_details 
    JOIN orders ON order_details.order_id = orders.order_id
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    GROUP BY pizza_types.category ), total_revenue AS
    ( SELECT SUM(total_revenue) AS overall_revenue FROM category_revenue )
    SELECT cr.pizza_type, cr.total_revenue, ROUND((cr.total_revenue / tr.overall_revenue) * 100, 2) AS percentage_contribution
    FROM category_revenue cr, total_revenue tr ORDER BY cr.total_revenue DESC LIMIT 3;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over (order by order_date ) as Cum_Revenue
from
( Select orders.order_date as order_date, round(sum(order_details.quantity*pizzas.price)) as Revenue
from orders
join order_details on orders.order_id = order_details.order_id
join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by order_date order by Revenue ) as sales;

-- determine the top 3 most ordered pizza types based on revenue for each pizza category
Select name, Revenue from
( Select category, name, Revenue,
rank() over (partition by category order by Revenue Desc) as rn
From
( select pizza_types.name, pizza_types.category, round(sum(order_details.quantity * pizzas.price)) as Revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
join orders on order_details.order_id = orders.order_id
group by pizza_types.name, pizza_types.category ) as a ) as b
where rn <=3;






