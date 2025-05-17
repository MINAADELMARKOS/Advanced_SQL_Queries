-- Connect to database (MySQL)
USE maven_advanced_sql;

-- ASSIGNMENT 1: Window function basics

-- View the orders table
SELECT	*
FROM	orders;

-- View the columns of interest
SELECT	customer_id, order_id, order_date, transaction_id
FROM	orders
ORDER BY customer_id, transaction_id;

-- For each customer, add a column for transaction number
SELECT	customer_id, order_id, order_date, transaction_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY transaction_id) AS transaction_num
FROM	orders
ORDER BY customer_id, transaction_id;

-- ASSIGNMENT 2: Row Number vs Rank vs Dense Rank

-- View the columns of interest
SELECT	order_id, product_id, units
FROM	orders;

-- Try ROW_NUMBER to rank the units
SELECT	order_id, product_id, units,
		ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rn
FROM	orders
ORDER BY order_id, product_rn;

-- For each order, rank the products from most units to fewest units
-- If there's a tie, keep the tie and don't skip to the next number after
SELECT	order_id, product_id, units,
		DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM	orders
ORDER BY order_id, product_rank;

-- Check the order id that ends with 44262 from the results preview
SELECT	order_id, product_id, units,
		DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM	orders
WHERE	order_id LIKE '%44262'
ORDER BY order_id, product_rank;

-- ASSIGNMENT 3: First Value vs Last Value vs Nth Value

-- View the rankings from the last assignment
SELECT	order_id, product_id, units,
		DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM	orders
ORDER BY order_id, product_rank;

-- Add a column that contains the 2nd most popular product
-- EDIT: This NTH_VALUE solution doesn't account for ties and returns inaccurate values. The DENSE_RANK solution below is the correct one.
SELECT	order_id, product_id, units,
		NTH_VALUE(product_id, 2) OVER(PARTITION BY order_id ORDER BY units DESC) AS second_product
FROM	orders
ORDER BY order_id, second_product;

-- Return the 2nd most popular product for each order
-- EDIT: This NTH_VALUE solution doesn't account for ties and returns inaccurate values. The DENSE_RANK solution below is the correct one.
SELECT * FROM

(SELECT	order_id, product_id, units,
		NTH_VALUE(product_id, 2) OVER(PARTITION BY order_id ORDER BY units DESC) AS second_product
FROM	orders
ORDER BY order_id, second_product) AS sp -- ORDER BY in subquery is not needed and can be omitted

WHERE product_id = second_product;

-- Alternative using DENSE RANK

-- Add a column that contains the rankings (this DENSE_RANK solution 
SELECT	order_id, product_id, units,
		DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM	orders
ORDER BY order_id, product_rank;

-- Return the 2nd most popular product for each order
SELECT * FROM

(SELECT	order_id, product_id, units,
		DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM	orders
ORDER BY order_id, product_rank) AS pr -- ORDER BY in subquery is not needed and can be omitted

WHERE product_rank = 2;

-- ASSIGNMENT 4: Lead & Lag

-- View the columns of interest
SELECT	customer_id, order_id, product_id, transaction_id, order_date, units
FROM	orders;

-- For each customer, return the total units within each order
SELECT	 customer_id, order_id, SUM(units) AS total_units
FROM	 orders
GROUP BY customer_id, order_id
ORDER BY customer_id;

-- Add on the transaction id to keep track of the order of the orders
SELECT	 customer_id, order_id, MIN(transaction_id) min_tid, SUM(units) AS total_units
FROM	 orders
GROUP BY customer_id, order_id
ORDER BY customer_id, min_tid;

-- Turn the query into a CTE and view the columns of interest
WITH my_cte AS (SELECT	 customer_id, order_id, MIN(transaction_id) min_tid, SUM(units) AS total_units
				FROM	 orders
				GROUP BY customer_id, order_id
				ORDER BY customer_id, min_tid)
                
SELECT	customer_id, order_id, total_units
FROM	my_cte;

-- Create a prior units column
WITH my_cte AS (SELECT	 customer_id, order_id, MIN(transaction_id) min_tid, SUM(units) AS total_units
				FROM	 orders
				GROUP BY customer_id, order_id
				ORDER BY customer_id, min_tid)
                
SELECT	customer_id, order_id, total_units,
		LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units
FROM	my_cte;

-- For each customer, find the change in units per order over time

-- APPROACH 1: One CTE - more concise approach
WITH my_cte AS (SELECT	 customer_id, order_id, MIN(transaction_id) AS min_tid, SUM(units) AS total_units
				FROM	 orders
				GROUP BY customer_id, order_id
				ORDER BY customer_id, min_tid) -- ORDER BY in CTE is not needed and can be omitted
                
SELECT	customer_id, order_id, total_units,
		LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units,
        total_units - LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid)
FROM	my_cte;

-- APPROACH 2: Multiple CTEs - step-by-step approach
WITH my_cte AS (SELECT	 customer_id, order_id, MIN(transaction_id) min_tid, SUM(units) AS total_units
				FROM	 orders
				GROUP BY customer_id, order_id
				ORDER BY customer_id, min_tid), -- ORDER BY in CTE is not needed and can be omitted
                
	 prior_cte AS (SELECT	customer_id, order_id, total_units,
							LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units
				   FROM		my_cte)
                
SELECT	customer_id, order_id, total_units, prior_units,
		total_units - prior_units AS diff_units
FROM	prior_cte;

-- ASSIGNMENT 5: NTILE

-- Calculate the total amount spent by each customer

-- View the data needed from the orders table
SELECT	customer_id, product_id, units
FROM	orders;

-- View the data needed from the products table
SELECT	product_id, unit_price
FROM	products;

-- Combine the two tables and view the columns of interest
SELECT	o.customer_id, o.product_id, o.units, p.unit_price
FROM	orders o LEFT JOIN products p
		ON o.product_id = p.product_id;
        
-- Calculate the total spending by each customer and sort the results from highest to lowest
SELECT	o.customer_id, SUM(o.units * p.unit_price) AS total_spend
FROM	orders o LEFT JOIN products p
		ON o.product_id = p.product_id
GROUP BY o.customer_id
ORDER BY total_spend DESC;

-- Turn the query into a CTE and apply the percentile calculation
WITH ts AS (SELECT	o.customer_id, SUM(o.units * p.unit_price) AS total_spend
			FROM	orders o LEFT JOIN products p
					ON o.product_id = p.product_id
			GROUP BY o.customer_id
			ORDER BY total_spend DESC)
            
SELECT	customer_id, total_spend,
		NTILE(100) OVER(ORDER BY total_spend DESC) AS spend_pct
FROM	ts;

-- Return the top 1% of customers in terms of spending
WITH ts AS (SELECT	o.customer_id, SUM(o.units * p.unit_price) AS total_spend
			FROM	orders o LEFT JOIN products p
					ON o.product_id = p.product_id
			GROUP BY o.customer_id
			ORDER BY total_spend DESC), -- ORDER BY in CTE is not needed and can be omitted
            
	 sp AS (SELECT	customer_id, total_spend,
					NTILE(100) OVER(ORDER BY total_spend DESC) AS spend_pct
			FROM	ts)
            
SELECT	*
FROM	sp
WHERE	spend_pct = 1;
