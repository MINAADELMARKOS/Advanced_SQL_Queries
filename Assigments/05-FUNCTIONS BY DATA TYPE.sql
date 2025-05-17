-- Connect to database (MySQL)
USE maven_advanced_sql;

-- ASSIGNMENT 1: Duplicate values

-- View the students data
SELECT * FROM students;

-- Create a column that counts the number of times a student appears in the table
SELECT 	*,
		ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY id DESC) AS student_count
FROM	students;

-- Return student ids, names and emails, excluding duplicates students
WITH sc AS (SELECT 	id, student_name, email,
					ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY id DESC) AS student_count
			FROM	students)
            
SELECT	id, student_name, email
FROM	sc
WHERE	student_count = 1;

-- ASSIGNMENT 2: Min / max value filtering

-- View the students and student grades tables
SELECT * FROM students;
SELECT * FROM student_grades;

-- For each student, return the classes they took and their final grades
SELECT	s.id, s.student_name, sg.class_name, sg.final_grade
FROM	students s LEFT JOIN student_grades sg
		ON s.id = sg.student_id;
        
-- Return each student's top grade and corresponding class:

-- APPROACH 1: GROUP BY + JOIN
        
-- For each student, return their highest grade
SELECT	 s.id, s.student_name, MAX(sg.final_grade) AS top_grade
FROM	 students s INNER JOIN student_grades sg
		 ON s.id = sg.student_id
GROUP BY s.id, s.student_name
ORDER BY s.id;

-- Final GROUP BY + JOIN query
WITH tg AS (SELECT	 s.id, s.student_name, MAX(sg.final_grade) AS top_grade
			FROM	 students s INNER JOIN student_grades sg
					 ON s.id = sg.student_id
			GROUP BY s.id, s.student_name
			ORDER BY s.id) -- ORDER BY in CTE is not needed and can be omitted
            
SELECT	tg.id, tg.student_name, tg.top_grade, sg.class_name
FROM	tg LEFT JOIN student_grades sg
		ON tg.id = sg.student_id AND tg.top_grade = sg.final_grade;

-- APPROACH 2: Window function

-- Rank the student grades for each student
SELECT	s.id, s.student_name, sg.class_name, sg.final_grade,
		DENSE_RANK() OVER (PARTITION BY s.student_name ORDER BY sg.final_grade DESC) AS grade_rank
FROM	students s LEFT JOIN student_grades sg
		ON s.id = sg.student_id;
        
-- Final window function query
SELECT id, student_name, class_name, final_grade FROM

(SELECT	s.id, s.student_name, sg.class_name, sg.final_grade,
		DENSE_RANK() OVER (PARTITION BY s.student_name ORDER BY sg.final_grade DESC) AS grade_rank
FROM	students s LEFT JOIN student_grades sg
		ON s.id = sg.student_id) AS gr
        
WHERE grade_rank = 1;
                    
-- ASSIGNMENT 3: Pivoting

-- Combine the students and student grades tables
SELECT * FROM students;
SELECT * FROM student_grades;

SELECT	*
FROM	students s LEFT JOIN student_grades sg
		ON s.id = sg.student_id;
        
-- View only the columns of interest
SELECT	s.grade_level, sg.department, sg.final_grade
FROM	students s LEFT JOIN student_grades sg
		ON s.id = sg.student_id;
        
-- Pivot the grade_level column
SELECT	sg.department, sg.final_grade,
		CASE WHEN s.grade_level = 9 THEN 1 ELSE 0 END AS freshman,
        CASE WHEN s.grade_level = 10 THEN 1 ELSE 0 END AS sophomore,
        CASE WHEN s.grade_level = 11 THEN 1 ELSE 0 END AS junior,
        CASE WHEN s.grade_level = 12 THEN 1 ELSE 0 END AS senior
FROM	students s LEFT JOIN student_grades sg
		ON s.id = sg.student_id;
        
-- Update the values to be final grades
SELECT	sg.department,
		CASE WHEN s.grade_level = 9 THEN sg.final_grade END AS freshman,
        CASE WHEN s.grade_level = 10 THEN sg.final_grade END AS sophomore,
        CASE WHEN s.grade_level = 11 THEN sg.final_grade END AS junior,
        CASE WHEN s.grade_level = 12 THEN sg.final_grade END AS senior
FROM	students s LEFT JOIN student_grades sg
		ON s.id = sg.student_id;

-- Create the final summary table
SELECT	 sg.department,
		 ROUND(AVG(CASE WHEN s.grade_level = 9 THEN sg.final_grade END)) AS freshman,
         ROUND(AVG(CASE WHEN s.grade_level = 10 THEN sg.final_grade END)) AS sophomore,
         ROUND(AVG(CASE WHEN s.grade_level = 11 THEN sg.final_grade END)) AS junior,
         ROUND(AVG(CASE WHEN s.grade_level = 12 THEN sg.final_grade END)) AS senior
FROM	 students s LEFT JOIN student_grades sg
		 ON s.id = sg.student_id
WHERE	 sg.department IS NOT NULL
GROUP BY sg.department
ORDER BY sg.department;

-- ASSIGNMENT 4: Rolling calculations

-- Calculate the total sales each month
SELECT	 YEAR(o.order_date) AS yr, MONTH(o.order_date) AS mnth, SUM(o.units * p.unit_price) AS total_sales
FROM	 orders o LEFT JOIN products p
		 ON o.product_id = p.product_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY YEAR(o.order_date), MONTH(o.order_date);

-- Add on the cumulative sum and 6 month moving average
WITH ms AS (SELECT	 YEAR(o.order_date) AS yr, MONTH(o.order_date) AS mnth,
						SUM(o.units * p.unit_price) AS total_sales
			FROM	 orders o LEFT JOIN products p
					 ON o.product_id = p.product_id
			GROUP BY YEAR(o.order_date), MONTH(o.order_date)
			ORDER BY YEAR(o.order_date), MONTH(o.order_date)) -- ORDER BY in CTE is not needed and can be omitted
            
SELECT	yr, mnth, total_sales,
        SUM(total_sales) OVER (ORDER BY yr, mnth) AS cumulative_sum,
        AVG(total_sales) OVER (ORDER BY yr, mnth ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
			AS six_month_ma
FROM	ms;
