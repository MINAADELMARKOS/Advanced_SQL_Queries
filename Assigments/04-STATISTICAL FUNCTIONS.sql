-- Connect to database (MySQL)
USE maven_advanced_sql;

-- ASSIGNMENT 1: Numeric functions

-- Calculate the total spend for each customer
SELECT o.customer_id, o.product_id, o.units
FROM orders o;

SELECT p.product_id, p.unit_price
FROM products p;

SELECT	o.customer_id, SUM(o.units * p.unit_price) AS total_spend
FROM	orders o LEFT JOIN products p
		ON o.product_id = p.product_id
GROUP BY o.customer_id;

-- Put the spend into bins of $0-$10, $10-20, etc.
SELECT	o.customer_id,
		SUM(o.units * p.unit_price) AS total_spend,
        FLOOR(SUM(o.units * p.unit_price) / 10) * 10 AS total_spend_bin
FROM	orders o LEFT JOIN products p
		ON o.product_id = p.product_id
GROUP BY o.customer_id;

-- Number of customers in each spend bin
WITH bin AS (SELECT	o.customer_id,
					SUM(o.units * p.unit_price) AS total_spend,
					FLOOR(SUM(o.units * p.unit_price) / 10) * 10 AS total_spend_bin
			 FROM	orders o LEFT JOIN products p
					ON o.product_id = p.product_id
			 GROUP BY o.customer_id)
             
SELECT	 total_spend_bin, COUNT(customer_id) AS num_customers
FROM	 bin
GROUP BY total_spend_bin
ORDER BY total_spend_bin;

-- ASSIGNMENT 2: Datetime functions

-- Extract just the orders from Q2 2024
SELECT	*
FROM	orders
WHERE	YEAR(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;

-- Add a column called ship_date that adds 2 days to each order date
SELECT	order_id, order_date,
		DATE_ADD(order_date, INTERVAL 2 DAY) AS ship_date
FROM	orders
WHERE	YEAR(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;

/*	This function varies by RDBMS:
- MySQL:	  DATE_ADD(order_date, INTERVAL 2 DAY)
- Oracle: 	  order_date + INTERVAL '2' DAY
- PostgreSQL: order_date + INTERVAL '2 days'
- SQL Server: DATEADD(DAY, 2, order_date)
- SQLite:	  DATE(order_date, '+2 days')
*/

-- ASSIGNMENT 3: String functions

-- View the current factory names and product IDs
SELECT	factory, product_id
FROM	products
ORDER BY factory, product_id;

-- Remove apostrophes and replace spaces with hyphens
SELECT	factory, product_id,
		REPLACE(REPLACE(factory, "'", ""), " ", "-") AS factory_clean
FROM	products
ORDER BY factory, product_id;

-- Create new ID column called factory_product_id
WITH fp AS (SELECT	factory, product_id,
					REPLACE(REPLACE(factory, "'", ""), " ", "-") AS factory_clean
			FROM	products
			ORDER BY factory, product_id) -- ORDER BY in CTE is not needed and can be omitted
            
SELECT	factory_clean, product_id,
		CONCAT(factory_clean, "-", product_id) AS factory_product_id
FROM	fp;

/* 	The CONCAT function will work in MySQL and SQL Server
	In Oracle, PostgreSQL and SQLite, use the following instead:
	factory_clean || '-' || product_id AS factory_product_id
*/

-- ASSIGNMENT 4: Pattern matching

-- View the product names
SELECT	 product_name
FROM	 products
ORDER BY product_name;

-- Only extract text after the hyphen for Wonka Bars
SELECT	 product_name,
		 REPLACE(product_name, 'Wonka Bar - ', '') AS new_product_name
FROM	 products
ORDER BY product_name;

-- Alternative using substrings
SELECT	 product_name,
		 CASE WHEN INSTR(product_name, '-') = 0 THEN product_name
			  ELSE SUBSTR(product_name, INSTR(product_name, '-') + 2) END AS new_product_name
FROM	 products
ORDER BY product_name;

/* The INSTR and SUBSTR functions will work in MySQL, Oracle and SQLite
	
    In PostgreSQL, use:
    POSITION('-' IN product_name) = 0
    SUBSTRING(product_name FROM POSITION('-' IN product_name) + 2)
    
    In SQL Server, use:
    CHARINDEX('-', product_name) = 0
    SUBSTRING(product_name, CHARINDEX('-', product_name) + 2, LEN(product_name)) 
    
*/

-- ASSIGNMENT 5: Null functions

-- View the columns of interest
SELECT	product_name, factory, division
FROM	products
ORDER BY factory, division;

-- Replace NULL values with Other
SELECT	product_name, factory, division,
		COALESCE(division, 'Other') AS division_other
FROM	products
ORDER BY factory, division;

-- Find the most common division for each factory
SELECT	factory, division, COUNT(product_name) AS num_products
FROM	products
WHERE	division IS NOT NULL
GROUP BY factory, division
ORDER BY factory, division;

-- Replace NULL values with top division for each factory
WITH np AS (SELECT	factory, division, COUNT(product_name) AS num_products
			FROM	products
			WHERE	division IS NOT NULL
			GROUP BY factory, division
			ORDER BY factory, division),
            
	 np_rank AS (SELECT	factory, division, num_products,
						ROW_NUMBER() OVER(PARTITION BY factory ORDER BY num_products DESC) AS np_rank
				 FROM	np)
                 
SELECT	factory, division
FROM	np_rank
WHERE	np_rank = 1;

-- Replace division with Other value and top division
WITH np AS (SELECT	factory, division, COUNT(product_name) AS num_products
			FROM	products
			WHERE	division IS NOT NULL
			GROUP BY factory, division
			ORDER BY factory, division), -- ORDER BY in CTE is not needed and can be omitted
            
	 np_rank AS (SELECT	factory, division, num_products,
						ROW_NUMBER() OVER(PARTITION BY factory ORDER BY num_products DESC) AS np_rank
				 FROM	np),
                 
	 top_div AS (SELECT	factory, division
				 FROM	np_rank
				 WHERE	np_rank = 1)

SELECT	 p.product_name, p.factory, p.division,
		 COALESCE(p.division, 'Other') AS division_other,
         COALESCE(p.division, td.division) AS division_top
FROM	 products p LEFT JOIN top_div td
		 ON p.factory = td.factory
ORDER BY p.factory, p.division;
