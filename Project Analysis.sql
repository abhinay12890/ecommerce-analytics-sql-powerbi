/* =====================================================
   E-COMMERCE ANALYTICS PROJECT (OLIST DATASET)
   ===================================================== */

use customers;

/* =====================================================
   1. DATA VALIDATION
   ===================================================== */

-- Row counts
select count(*) from customer;
select count(*) from order_items;
select count(*) from orders;
select count(*) from order_payments;
select count(*) from products;

-- Total Revenue
select round(sum(payment_value),2) as total_revenue from order_payments;

-- Total Orders
select count(distinct order_id) as total_orders from orders;

-- Total Customers
select count(distinct customer_id) as total_customers from customer;

-- Average Order Value
SELECT ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS average_payment 
FROM order_payments;

/* =====================================================
   2. REVENUE TREND ANALYSIS
   Business Question:
   How has revenue changed over time?
   ===================================================== */
   
select date_format(o.order_purchase_timestamp,'%Y-%m') as order_month,
round(sum(op.payment_value),2) as revenue, round(sum(op.payment_value)- lag(sum(op.payment_value)) over (order by date_format(o.order_purchase_timestamp,'%Y-%m')),2) as revenue_change
from orders as o
inner join order_payments as op
on o.order_id=op.order_id
group by order_month
order by order_month;

/* =====================================================
   3. PRODUCT CATEGORY ANALYSIS
   Business Question:
   Which product categories generate the highest revenue?
   ===================================================== */

select p.product_category_name, ROUND(SUM(oi.price),2) as total_revenue, COUNT(DISTINCT oi.order_id) as total_orders, SUM(oi.price)/COUNT(DISTINCT oi.order_id) as average_revenue from order_items as oi
inner join products as p 
on oi.product_id=p.product_id
group by p.product_category_name
order by total_revenue desc;

/* =====================================================
   4. CATEGORY PARETO ANALYSIS
   Business Question:
   Do a small number of categories drive most revenue?
   ===================================================== */

with temp as (select p.product_category_name as cat_name, ROUND(SUM(oi.price),2) as total_revenue from order_items as oi
inner join products as p 
on oi.product_id=p.product_id
group by p.product_category_name)

select cat_name, round(total_revenue*100/(SUM(total_revenue) OVER()),2) as revenue_per, SUM(total_revenue) over (order by total_revenue desc)*100 / SUM(total_revenue) OVER() as running_revenue from temp
order by total_revenue desc;

/* =====================================================
   5. CUSTOMER REVENUE ANALYSIS
   Business Question:
   Which customers generate the most revenue?
   ===================================================== */
select o.customer_id, sum(payment_value) as payment from orders as o
inner join customer as c
on o.customer_id=c.customer_id
inner join order_payments as op
on o.order_id=op.order_id
group by o.customer_id
order by payment desc;

/* =====================================================
   6. CUSTOMER PARETO ANALYSIS
   Business Question:
   Is customer revenue concentrated among a small group?
   ===================================================== */

with temp as (select o.customer_id, SUM(price) as total_revenue from orders as o
inner join order_items as oi 
on o.order_id=oi.order_id
group by o.customer_id)

select *, round(total_revenue*100/sum(total_revenue) over(),2) as revenue_pct, SUM(total_revenue) over(order by total_revenue desc)*100/ sum(total_revenue) over() as running_revenue_pct from temp
order by revenue_pct desc;

/* =====================================================
   7. RECENCY ANALYSIS
   Business Question:
   When did each customer last make a purchase?
   ===================================================== */
   
SELECT
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_purchase
FROM customer c
JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;


/* =====================================================
   8. FREQUENCY ANALYSIS
   Business Question:
   How often do customers purchase?
   ===================================================== */
select c.customer_unique_id, count(distinct o.order_id) as frequency, max(o.order_purchase_timestamp) as last_purchase from customer as c
inner join orders as o
on c.customer_id=o.customer_id
group by c.customer_unique_id
order by frequency desc;

/* =====================================================
   9. MONETARY ANALYSIS
   Business Question:
   Who are the highest-spending customers and how much revenue does each customer contribute?
   ===================================================== */
select c.customer_id, sum(op.payment_value) as revenue, sum(op.payment_value)*100/sum(sum(op.payment_value)) over() as revenue_pct  from customer as c
inner join orders as o 
on o.customer_id=c.customer_id
inner join order_payments as op
on o.order_id=op.order_id
group by c.customer_id
order by revenue_pct desc;

/* =====================================================
   10. GEOGRAPHIC REVENUE ANALYSIS
   Business Question:
   Which states contribute the most revenue?
   ===================================================== */
select c.customer_state, round(sum(op.payment_value),2) as Revenue from customer as c
inner join orders as o
on o.customer_id=c.customer_id
inner join order_payments as op
on op.order_id=o.order_id
group by c.customer_state
order by Revenue desc;
