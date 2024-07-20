-- Calculate the average order amount for each country
SELECT c.country, AVG(od.priceEach * od.quantityOrdered) AS average_order_amount
FROM classicmodels.customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od
ON od.orderNumber = o.orderNumber 
GROUP BY country
ORDER BY average_order_amount;

-- Calculate the total sales amount for each product line
SELECT p.productline, SUM(od.quantityOrdered * od.priceEach) as sales_for_product_line
FROM classicmodels.products p
INNER JOIN orderdetails od 
ON od.productCode = p.productCode
GROUP BY productline
ORDER BY sales_for_product_line desc;

-- List the top 10 best-selling products based on total quantity sold
SELECT p.productName, SUM(od.quantityOrdered) as total_quantity_sold
FROM classicmodels.products p
INNER JOIN orderdetails od 
ON od.productCode = p.productCode
GROUP BY productName 
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Evaluate the sales performance of each sales representative
SELECT e.firstName as FIRST_NAME, e.lastName as LAST_NAME, SUM(p.amount) as Sales_performance
FROM employees e
LEFT JOIN customers c 
ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN payments p
ON c.customerNumber = p.customerNumber
GROUP BY firstName, lastName
ORDER BY Sales_performance DESC;

-- Calculate the average number of orders placed by each customer

SELECT COUNT(o.orderNumber) / COUNT(DISTINCT c.customerNumber) AS avg_orders_per_customer
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber;

-- Calculate the percentage of orders that were shipped on time
SELECT SUM(CASE WHEN shippedDate <= requiredDate THEN 1 ELSE 0 END) / COUNT(orderNumber) * 100 AS percent_on_time
FROM classicmodels.orders;

-- Calculate the profit margin for each product by subtracting the cost of goods sold (COGS) from the sales revenue
SELECT p.productName, (SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice)) as profit 
FROM products p 
JOIN orderdetails od
ON od.productCode = p.productCode
GROUP BY productName;

-- Segment customers based on their total purchase amount
SELECT t1.customerName, total_purchase,
CASE WHEN total_purchase < 50000 THEN 'LOW'
WHEN total_purchase > 100000 THEN 'HIGH'
ELSE 'MID'
END AS customer_segment
FROM
(SELECT c.customerName, SUM(od.quantityOrdered * od.priceEach) as total_purchase
FROM customers c
JOIN orders o 
ON c.customerNumber = o.customerNumber
JOIN orderdetails od
ON od.orderNumber = o.orderNumber
GROUP BY customerName
ORDER BY total_purchase) as T1;

-- Identify frequently co-purchased products to understand cross-selling opportunities
SELECT od.productCode, p.productName, od2.productCode, p2.productName, count(*) as purchased_together from orderdetails od 
INNER JOIN orderdetails od2
ON od.orderNumber = od2.orderNumber AND od.productCode != od2.productCode
INNER JOIN products p
ON od.productCode = p.productCode
INNER JOIN products p2
ON od2.productCode = p2.productCode
GROUP BY od.productCode, p.productName, od2.productCode, p2.productName
ORDER BY purchased_together desc;
