-- my first select statement
SELECT * FROM teachers;

-- only showing certain columns
SELECT last_name, first_name, salary FROM teachers;

-- looking for different values
SELECT DISTINCT school
FROM teachers;

-- we can also look in more than one table
SELECT DISTINCT school, salary
FROM teachers;--salary is two because school does not match

-- sorting the data by salary can help us, default is ASC
SELECT first_name, last_name, salary
FROM teachers
ORDER BY salary DESC;

-- we can use sort more than once
SELECT last_name, school, hire_date
FROM teachers
ORDER BY school ASC, hire_date DESC;

-- we can limit the data we get back with the WHERE statement
SELECT last_name, school, hire_date
FROM teachers
WHERE school = 'Myers Middle School';

SELECT first_name, last_name, school
FROM teachers
WHERE first_name = 'Janet';

-- returns all not that value we specified
SELECT school
FROM teachers
WHERE school != 'F.D. Roosevelt HS';

-- returns smaller dates then specified
SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '2000-01-01';

-- returns salaries bigger or equal to specified
SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 43500;

-- in between values specified we can get all data
SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary BETWEEN 40000 AND 65000;

-- %one or more characters match, _only one character match
SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%';
--LIKE case sensitive and ILIKE is not
SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam%';

-- using operators more than once in select statements
SELECT * --get all columns
FROM teachers--name of your table
WHERE school = 'Myers Middle School' AND salary < 40000;
--conditions that should be true

SELECT * --get all columns
FROM teachers--name of your table
WHERE last_name = 'Cole' OR last_name = 'Bush';
--conditions that should be true

SELECT * --get all columns
FROM teachers--name of your table
WHERE school = 'F.D. Roosevelt HS' AND (salary < 38000 OR salary > 40000);
--conditions that should be true

SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC;
