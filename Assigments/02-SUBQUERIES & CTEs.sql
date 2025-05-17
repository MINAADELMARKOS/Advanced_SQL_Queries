-- Connect to database (MySQL)
USE maven_advanced_sql;

-- ASSIGNMENT 1: Subqueries in the SELECT clause

-- View the products table
SELECT * FROM products;

-- View the average unit price
SELECT AVG(unit_price) FROM products;

-- Return the product id, product name, unit price, average unit price,
-- and the difference between each unit price and the average unit price
SELECT	product_id, product_name, unit_price,
		(SELECT AVG(unit_price) FROM products) AS avg_unit_price,
        unit_price - (SELECT AVG(unit_price) FROM products) AS diff_price
FROM	products;

-- Order the results from most to least expensive
SELECT	 product_id, product_name, unit_price,
		 (SELECT AVG(unit_price) FROM products) AS avg_unit_price,
         unit_price - (SELECT AVG(unit_price) FROM products) AS diff_price
FROM	 products
ORDER BY unit_price DESC;

-- ASSIGNMENT 2: Subqueries in the FROM clause

-- Return the factories, product names from the factory
-- and number of products produced by each factory

-- All factories and products
SELECT	factory, product_name
FROM	products;

-- All factories and their total number of products
SELECT	 factory, COUNT(product_id) AS num_products
FROM	 products
GROUP BY factory;

-- Final query with subqueries
SELECT	fp.factory, fp.product_name, fn.num_products
FROM

(SELECT	factory, product_name
FROM	products) fp

LEFT JOIN

(SELECT	 factory, COUNT(product_id) AS num_products
FROM	 products
GROUP BY factory) fn

ON fp.factory = fn.factory
ORDER BY fp.factory, fp.product_name;

-- ASSIGNMENT 3: Subqueries in the WHERE clause

-- View all products from Wicked Choccy's
SELECT	*
FROM	products
WHERE	factory = "Wicked Choccy's";

-- Return products where the unit price is less than
-- the unit price of all products from Wicked Choccy's
SELECT	*
FROM	products
WHERE	unit_price <
		ALL (SELECT	unit_price
			 FROM	products
			 WHERE	factory = "Wicked Choccy's");

-- ASSIGNMENT 4: CTEs

-- View the orders and products tables
SELECT * FROM orders;
SELECT * FROM products;

-- Calculate the amount spent on each product, within each order
SELECT	o.order_id, o.product_id, o.units, p.unit_price,
		o.units * p.unit_price AS amount_spent
FROM	orders o LEFT JOIN products p
		ON o.product_id = p.product_id;

-- Return all orders over $200
SELECT	 o.order_id,
		 SUM(o.units * p.unit_price) AS total_amount_spent
FROM	 orders o LEFT JOIN products p
		 ON o.product_id = p.product_id
GROUP BY o.order_id
HAVING   total_amount_spent > 200
ORDER BY total_amount_spent DESC;

-- Return the number of orders over $200
WITH tas AS (SELECT	 o.order_id,
					 SUM(o.units * p.unit_price) AS total_amount_spent
			 FROM	 orders o LEFT JOIN products p
					 ON o.product_id = p.product_id
			 GROUP BY o.order_id
			 HAVING   total_amount_spent > 200
			 ORDER BY total_amount_spent DESC)
			
			/* This ORDER BY clause in the CTE doesn't affect the final output
			   and can be removed to make the code run more efficiently */
             
SELECT	COUNT(*)
FROM	tas;

-- ASSIGNMENT 5: Multiple CTEs

-- Copy over Assignment 2 (Subqueries in the FROM clause) solution
SELECT	fp.factory, fp.product_name, fn.num_products
FROM

(SELECT	factory, product_name
FROM	products) fp

LEFT JOIN

(SELECT	 factory, COUNT(product_id) AS num_products
FROM	 products
GROUP BY factory) fn

ON fp.factory = fn.factory
ORDER BY fp.factory, fp.product_name;

-- Rewrite the Assignment 2 subquery solution using CTEs instead
WITH fp AS (SELECT factory, product_name FROM products),
	 fn AS (SELECT	 factory, COUNT(product_id) AS num_products
			FROM	 products
			GROUP BY factory)

SELECT	fp.factory, fp.product_name, fn.num_products
FROM	fp LEFT JOIN fn
		ON fp.factory = fn.factory
ORDER BY fp.factory, fp.product_name;
