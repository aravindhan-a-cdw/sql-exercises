-- Q1: Write a SQL query to remove the details of an employee whose first name ends in ‘even’
SELECT * FROM employees WHERE first_name LIKE '%even';
DELETE FROM employees WHERE first_name LIKE '%even';

-- Q2: Write a query in SQL to show the three minimum values of the salary from the table.
SELECT salary FROM employees_table ORDER BY salary LIMIT 3;

-- Q3: Write a SQL query to copy the details of this table into a new table with table name as Employee table and to delete the records in employees table
CREATE TABLE employees_table AS SELECT * FROM employees;
DELETE FROM employees;

-- Add age column to remove it
ALTER TABLE employees ADD COLUMN age INT;

-- Q4: Write a SQL query to remove the column Age from the table
ALTER TABLE employees DROP COLUMN age;

-- Q5: Obtain the list of employees (their full name, email, hire_year) where they have joined the firm before 2000
SELECT concat(first_name, ' ', last_name) AS "FULL NAME", email, date_part(YEAR, HIRE_DATE) AS hire_year FROM employees_table
WHERE hire_year < 2000;

-- Q6: Fetch the employee_id and job_id of those employees whose start year lies in the range of 1990 and 1999
-- Way 1
SELECT employee_id, job_id FROM JOB_HISTORY WHERE start_date >= to_date('1990-01-01') AND start_date <= to_date('1999-12-31');
-- Way 2
SELECT employee_id, job_id FROM JOB_HISTORY WHERE date_part(YEAR, start_date) > 1990 AND date_part(YEAR, start_date) <= 1999;
-- Way 3
SELECT employee_id, job_id FROM JOB_HISTORY WHERE date_part(YEAR, start_date) BETWEEN 1990 and 1999;

-- Q7: Find the first occurrence of the letter 'A' in each employees Email ID Return the employee_id, email id and the letter position
SELECT employee_id, email, position('A', email, 1) AS letter_position FROM employees_table WHERE letter_position != 0;

-- Q8: Fetch the list of employees(Employee_id, full name, email) whose full name holds characters less than 12
SELECT employee_id, concat(first_name, ' ', last_name) AS "FULL NAME", email, length("FULL NAME") FROM employees_table WHERE length("FULL NAME") < 12;

-- Q9: Create a unique string by hyphenating the first name, last name , and email of the employees to obtain a new field named UNQ_ID 
-- Return the employee_id, and their corresponding UNQ_ID;
SELECT employee_id, concat(first_name, '-', last_name, '-', email) as UNQ_ID FROM employees_table;

-- Q10: Write a SQL query to update the size of email column to 30
ALTER TABLE employees MODIFY email VARCHAR(30);
-- Note: Size reducing is not supported.

-- Q11: Write a SQL query to change the location of Diana to London
select * from employees_table WHERE first_name like 'Diana';
SELECT * FROM departments;
select * from locations;

UPDATE employees_table 
SET department_id = (
    SELECT department_id FROM departments 
    WHERE LOCATION_ID = (
        SELECT LOCATION_ID FROM locations 
        WHERE city = 'London'
        )
    ) 
WHERE first_name = 'Diana';
-- Doubt: This cannot be done without employee having a location field



-- Q12: Fetch all employees with their first name , email , phone (without extension part) and extension (just the extension)
-- Info : this mean you need to separate phone into 2 parts
-- eg: 123.123.1234.12345 => 123.123.1234 and 12345 . first half in phone column and second half in extension column
SELECT 
    first_name, 
    email, 
    phone_number,
    (split(phone_number, '.')) as array,
    array_to_string(array_slice(split(phone_number, '.'), 0, (array_size(split(phone_number, '.')) - 1) ), '.') as phone, 
    -- array_to_string(array_slice(split(phone_number, '.'), -1, array_size(split(phone_number, '.'))), '') as extension
    split_part(phone_number, '.', -1) as extension
FROM employees_table;


-- Q13: Write a SQL query to find the employee with second and third maximum salary with and without using top/limit keyword
-- Way 1
select DISTINCT salary from employees_table order by salary desc;
-- Way 2
SELECT DISTINCT salary FROM employees_table 
WHERE salary < (SELECT max(salary) from employees_table)
ORDER BY salary DESC limit 2;
-- Way 3
SELECT DISTINCT salary from employees_table ORDER BY salary DESC limit 2 offset 1;
-- Way 4
SELECT DISTINCT salary from employees_table
ORDER BY salary DESC
OFFSET 1 FETCH 2 ROWS ONLY;
-- Way 5
SELECT salary from employees_table 
WHERE salary >= (
SELECT (SELECT max(salary) from employees_table 
where salary < (
SELECT (SELECT max(salary) from employees_table
WHERE salary < (SELECT max(salary) from employees_table)) as second_salary)) as third_salary)
AND salary < (SELECT max(salary) from employees_table);
-- Doubt: Need to select employee and not the salary. Hence use rank to get employee_id and display the 2nd and 3rd highest


-- Q14: Fetch all details of top 3 highly paid employees who are in department Shipping and IT
SELECT * FROM employees_table 
WHERE department_id IN (SELECT department_id FROM departments WHERE department_name IN ('Shipping', 'IT'))
ORDER BY salary DESC LIMIT 3;

-- Q15: Display employee id and the positions(jobs) held by that employee (including the current position)

SELECT employee_id, listagg(job_id, ', ') AS positions 
FROM (SELECT employee_id, job_id FROM employees_table UNION SELECT employee_id, job_id FROM job_history) 
GROUP BY employee_id ORDER BY employee_id;

SELECT employee_id, job_id FROM employees_table UNION SELECT employee_id, job_id FROM job_history ORDER BY EMPLOYEE_ID;


-- Q16: Display Employee first name and date joined as WeekDay, Month Day, Year
SELECT first_name, concat(dayname(HIRE_DATE), ', ', monthname(HIRE_DATE), ' ', day(HIRE_DATE), ', ', year(HIRE_DATE) ) as hired_date from employees_table;

-- Q17: The company holds a new job opening for Data Engineer (DT_ENGG) with a minimum salary of 12,000 and maximum salary of 30,000 . The job position might be removed based on market trends (so, save the changes) . - Later, update the maximum salary to 40,000 . - Save the entries as well.
-- - Now, revert back the changes to the initial state, where the salary was 30,000

ALTER SESSION SET AUTOCOMMIT = FALSE;

INSERT INTO jobs VALUES('DT_ENGG', 'Data Engineer', 12000, 30000);
select * from jobs;

COMMIT;

UPDATE jobs
SET max_salary = 40000
WHERE job_id = 'DT_ENGG';

select * from jobs;

ROLLBACK;

select * from jobs;

-- Q18: Find the average salary of all the employees who got hired after 8th January 1996 but before 1st January 2000 and round the result to 3 decimals

SELECT round(avg(salary), 3) AS avg_salary FROM employees_table
WHERE hire_date > date_from_parts(1996, 1, 8) and hire_date < date_from_parts(2000, 1, 1);

SELECT round(avg(salary), 3) AS avg_salary FROM employees_table
WHERE hire_date BETWEEN date_from_parts(1996, 1, 8) and date_from_parts(2000, 1, 1);

-- Q19: Display Australia, Asia, Antarctica, Europe along with the regions in the region table (Note: Do not insert data into the table)
-- A. Display all the regions
-- B. Display all the unique regions

SELECT REGION_NAME FROM regions 
UNION ALL SELECT 'Australia' AS REGION_NAME 
UNION ALL SELECT 'Asia' AS REGION_NAME
UNION ALL SELECT 'Antartica' AS REGION_NAME
UNION ALL SELECT 'Europe' AS REGION_NAME;

SELECT REGION_NAME FROM regions 
UNION SELECT 'Australia' AS REGION_NAME 
UNION SELECT 'Asia' AS REGION_NAME
UNION SELECT 'Antartica' AS REGION_NAME
UNION SELECT 'Europe' AS REGION_NAME;

-- Q20: Write a SQL query to remove the employees table from the database
DROP table employees;

