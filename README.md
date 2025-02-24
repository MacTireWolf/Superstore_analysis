# Superstore_analysis

# Superstore SQL Analysis Project

This project involves querying a hypothetical "Superstore" database, which contains data related to orders, products, customers, and returns. The primary objective is to analyze the sales, profitability, returns, and customer behaviors using SQL queries. Below is a detailed description of the SQL queries used in this project.

---

## Table of Contents

1. **Returned Orders**
2. **Total Value of Sales for Returned Orders**
3. **Customers Who Have Made Returns and the Number of Their Returns**
4. **Customers with an Average Order Value of More Than USD 500,000**
5. **Monthly Total Sales and Average Profit Per Month**
6. **Classification of Customers by Expenditure**
7. **Classification of Products by Profit**
8. **Orders with a Value Above the Regional Average**
9. **Customers Who Have Never Made a Return**
10. **Monthly Sales, Profit, and Returns (View)**
11. **Top 10 Best-Selling Products in Each Category (View)**
12. **Identification of Unprofitable Products**
13. **Analysis of Delivery Delays**
14. **Customers with the Highest Lifetime Value (LTV)**

---

## 1. Returned Orders

This query returns the total number of distinct orders that have been returned.

```sql
select 
    count(distinct so.order_id) as returned_orders
from superstore_orders so 
inner join superstore_returns sr on so.order_id = sr.order_id
```

---

## 2. Total Value of Sales for Returned Orders

This query calculates the total sales value for all the returned orders.

```sql
select
    sum(so.sales) as total_sales
from superstore_orders so 
inner join superstore_returns sr on so.order_id = sr.order_id
```

---

## 3. Customers Who Have Made Returns and the Number of Their Returns

This query returns a list of customers who have made returns, along with the number of their returned orders, ordered by the number of returns.

```sql
select
    so.customer_name as customers,
    count(distinct so.order_id) as returned_orders
from superstore_orders so 
inner join superstore_returns sr on so.order_id = sr.order_id
group by 1
order by 2 desc
```

---

## 4. Customers with an Average Order Value of More Than USD 500,000

This query returns a list of customers whose average order value exceeds USD 500,000.

```sql
with avg_sales as 
(
select
    customer_id as customers,
    avg(sales) as avg_sales
from superstore_orders
group by 1
)
select
    so.customer_name as customer,
    a.avg_sales
from superstore_orders so
join avg_sales a on so.customer_id = a.customers 
where a.avg_sales > 500000
group by 1,2
order by 2 desc
```

---

## 5. Monthly Total Sales and Average Profit Per Month

This query calculates the total sales and the average profit per month.

```sql
with monthly_sales as
(
select
    MONTH(order_date) as month,
    sum(sales) as sum_sales,
    avg(profit) as avg_profit
from superstore_orders
group by 1
)
select
    *
from monthly_sales
order by 1
```

---

## 6. Classification of Customers by Expenditure

This query classifies customers based on their total sales expenditure.

```sql
select
    customer_name,
    sum(sales) as sum_sales,
    case
        when sum(sales) > 10000 then 'VIP Client'
        when sum(sales) between 1000 and 10000 then 'Standard Client'
        else 'New Client'
    end as client_segment
from superstore_orders
group by 1
```

---

## 7. Classification of Products by Profit

This query classifies products based on whether they are profitable or non-profitable.

```sql
select
    product_id,
    product_name,
    sales,
    profit,
    case
        when profit > 0 then 'Profitable'
        else 'Non-profitable'
    end as profit_status
from superstore_orders
```

---

## 8. Orders with a Value Above the Regional Average

This query returns orders with a sales value higher than the average sales for the respective region.

```sql
select 
    *
from superstore_orders so
where sales > (
    select avg(sales)
    from superstore_orders
    where region = so.region
)
```

---

## 9. Customers Who Have Never Made a Return

This query identifies customers who have never made a return.

```sql
select
    so.customer_name  
from superstore_orders so
where customer_id not in (
    select distinct
    customer_id
    from superstore_returns sr
    join superstore_orders so on so.order_id = sr.order_id 
)
```

---

## 10. Monthly Sales, Profit, and Returns (View)

This view aggregates the total sales, total profit, and the number of returned orders per month.

```sql
create view monthly_performance as 
select 
    MONTH(so.order_date) as month_of_order,
    sum(so.sales) as total_sales,
    sum(so.profit) as total_profit,
    count(distinct sr.order_id) as number_of_returned_orders
from superstore_orders so
join superstore_returns sr on so.order_id = sr.order_id 
group by 1

select * from monthly_performance
```

---

## 11. Top 10 Best-Selling Products in Each Category (View)

This view ranks products within each category by their total sales and selects the top 10 products per category.

```sql
create view top_products as 
with ranked_products as 
(
select
    so.category,
    so.product_name,
    sum(sales) as total_sales,
    rank() over (partition by category order by sum(sales) desc) as sales_rank
from superstore_orders so
group by 1,2
)
select
    *
from ranked_products
where sales_rank <= 10

select * from top_products
```

---

## 12. Identification of Unprofitable Products

This query identifies products with negative profits.

```sql
select 
    so.product_id,
    so.product_name,
    sum(so.sales) as total_sales,
    sum(so.profit) as total_profit,
    count(distinct so.order_id) as order_count
from superstore_orders so
group by 1,2
having total_profit < 0
order by 5 desc
```

---

## 13. Analysis of Delivery Delays

This query calculates the average shipping delay for each product category and subcategory.

```sql
select
    so.category,
    so.sub_category,
    avg(so.ship_date - so.order_date) as avg_shipping_delay
from superstore_orders so
group by 1,2
order by 3 desc
```

---

## 14. Customers with the Highest Lifetime Value (LTV)

This query identifies the top 10 customers with the highest lifetime value (LTV) based on total sales and profit.

```sql
select
    so.customer_id,
    so.customer_name,
    sum(so.sales) as total_sales,
    sum(so.profit) as total_profit,
    count(distinct so.order_id) as order_count
from superstore_orders so 
group by 1,2
having total_profit > 0
order by 3 desc 
limit 10
```

---

## Conclusion

This project demonstrates a variety of SQL techniques for analyzing customer, sales, and product data. The queries cover topics such as returns analysis, sales performance, customer segmentation, product profitability, and shipping delays, which can be used for business intelligence and decision-making processes in retail.

