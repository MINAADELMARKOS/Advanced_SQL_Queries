# 📘 Advanced SQL Recap for Data Engineer

This repository provides a structured recap of essential and advanced SQL concepts, written as a study resource for data analysts. It is based on hands-on project-based learning and real-world querying scenarios.

# 🔍 Overview
This document is designed to help you:

Review advanced SQL syntax

Understand when and how to use complex queries

Practice advanced analytical functions and techniques

Prepare for real-world data analyst interviews and projects

# 🧠 Course Content Recap
1. ✅ SQL Basics Review
SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY

DISTINCT, LIMIT, aliases using AS

2. ✅ Multi-Table Analysis
INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN

SELF JOIN for comparing rows within the same table

CROSS JOIN for generating row combinations

UNION, UNION ALL for combining result sets

3. ✅ Subqueries & CTEs
Subqueries in SELECT, WHERE, and FROM clauses

Common Table Expressions (WITH ... AS)

Recursive CTEs for hierarchical or time-based problems

When to use subqueries, CTEs, temporary tables, or views

4. ✅ Window Functions
Window functions allow calculations across a set of table rows related to the current row:

ROW_NUMBER(), RANK(), DENSE_RANK()

FIRST_VALUE(), LAST_VALUE(), LEAD(), LAG()

OVER(PARTITION BY ... ORDER BY ...)

5. ✅ SQL Functions by Data Type
🧮 Numeric Functions:
ABS(), ROUND(), CEIL(), FLOOR(), POWER()

📅 Date/Time Functions:
NOW(), CURRENT_DATE, DATE_PART(), DATE_TRUNC()

🔤 String Functions:
CONCAT(), LENGTH(), SUBSTRING(), UPPER(), LOWER()

❓ NULL Handling:
IS NULL, IS NOT NULL, COALESCE(), NULLIF()

6. ✅ Data Analysis Applications
Removing duplicates using ROW_NUMBER() and filtering

Rolling calculations using window frames (ROWS BETWEEN)

Pivoting and unpivoting data for aggregation

Using CASE WHEN for conditional logic

