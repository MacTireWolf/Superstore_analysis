/* number of returned orders */
select 
	count(distinct so.order_id)	as returned_orders
from superstore_orders so 
inner join superstore_returns sr on so.order_id = sr.order_id

/* Total value of sales for returned orders */
select
	sum(so.sales) as total_sales
from superstore_orders so 
inner join superstore_returns sr on so.order_id = sr.order_id

/* Customers who have made returns and the number of their returns */
select
	so.customer_name				as customers
	,count(distinct so.order_id) 	as returned_orders
from superstore_orders so 
inner join superstore_returns sr on so.order_id = sr.order_id
group by 1
order by 2 desc

/* Customers with an average order value of more than USD 500000 */
with avg_sales as 
(
select
	customer_id as customers
	,avg(sales) as avg_sales
from superstore_orders
group by 1
)
select
	so.customer_name as customer
	,a.avg_sales
from superstore_orders so
join avg_sales a on so.customer_id = a.customers 
where a.avg_sales > 500000
group by 1,2
order by 2 desc

/* Monthly total sales and average profit per month */
with monthly_sales as
(
select
	MONTH(order_date) 	as month
	,sum(sales)			as sum_sales
	,avg(profit)		as avg_profit
from superstore_orders
group by 1
)
select
	*
from monthly_sales
order by 1

/* Classification of customers by expenditure */
select
	customer_name
	,sum(sales)	as sum_sales
	,case
		when sum(sales) > 10000 then 'VIP Client'
		when sum(sales) between 1000 and 10000 then 'Standard Client'
		else 'New Client'
	end as client_segment
from superstore_orders
group by 1

/* Classification of products by profit */
select
	product_id
	,product_name
	,sales
	,profit
	,case
		when profit > 0 then 'Profitable'
		else 'Non-profitable'
	end as profit_status
from superstore_orders

/* Orders with a value above the regional average */
select 
	*
from superstore_orders so
where sales > (
	select avg(sales)
	from superstore_orders
	where region = so.region
)

/* Customers who have never made a return */
select
	so.customer_name  
from superstore_orders so
where customer_id not in (
	select distinct
	customer_id
	from superstore_returns sr
	join superstore_orders so on so.order_id = sr.order_id 
)

/* View with monthly sales, profit and returns */
create view monthly_performance as 
select 
	MONTH(so.order_date) 				as month_of_order
	,sum(so.sales)						as total_sales
	,sum(so.profit) 					as total_profit
	,count(distinct sr.order_id) 		as number_of_returned_orders
from superstore_orders so
join superstore_returns sr on so.order_id = sr.order_id 
group by 1

select * from monthly_performance

/* View with the top 10 best-selling products in each category */
create view top_products as 
with ranked_products as 
(
select
	so.category 
	,so.product_name 
	,sum(sales) as total_sales
	,rank() over (partition by category order by sum(sales) desc) as sales_rank
from superstore_orders so
group by 1,2
)
select
	*
from ranked_products
where sales_rank <= 10

select * from top_products

/* Identification of unprofitable products */
select 
	so.product_id 
	,so.product_name 
	,sum(so.sales ) as total_sales
	,sum(so.profit ) as total_profit
	,count(distinct so.order_id ) as order_count
from superstore_orders so
group by 1,2
having total_profit < 0
order by 5 desc


/* Analysis of delivery delays */
select
	so.category 
	,so.sub_category 
	,avg(so.ship_date - so.order_date )	as avg_shipping_delay
from superstore_orders so
group by 1,2
order by 3 desc

/* Customers with the highest Lifetime Value (LTV) */
select
	so.customer_id 
	,so.customer_name 
	,sum(so.sales ) as total_sales
	,sum(so.profit ) as total_profit
	,count(distinct so.order_id ) as order_count
from superstore_orders so 
group by 1,2
having total_profit > 0
order by 3 desc 
limit 10