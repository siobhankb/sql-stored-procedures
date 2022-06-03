SELECT COUNT(*)
FROM actor 
WHERE last_name LIKE 'B%';

SELECT COUNT(*)
FROM actor 
WHERE last_name LIKE 'G%';


-- Create a stored function - give us a count of actors whose last name begins with *letter*
CREATE OR REPLACE FUNCTION count_actors_with_last_name(letter VARCHAR(1))
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
	DECLARE actor_count INTEGER;
BEGIN
	SELECT COUNT(*) INTO actor_count 
	FROM actor
	WHERE last_name LIKE CONCAT(letter, '%');

	RETURN actor_count;
END;
$$


-- Execute the function - use SELECT 
SELECT count_actors_with_last_name('A');





-- Create a function that will return the employee name with the most transactions (based on payments)

SELECT concat(first_name, ' ', last_name) AS employee
FROM staff s 
WHERE s.staff_id = (
	SELECT staff_id
	FROM payment p 
	GROUP BY staff_id 
	ORDER BY COUNT(*) DESC
	LIMIT 1
);


CREATE OR REPLACE FUNCTION employee_with_most_transactions()
RETURNS VARCHAR(100)
LANGUAGE plpgsql 
AS $$ 
	DECLARE employee VARCHAR(100);
BEGIN 
	SELECT concat(first_name, ' ', last_name) INTO employee
	FROM staff s 
	WHERE s.staff_id = (
		SELECT staff_id
		FROM payment p 
		GROUP BY staff_id 
		ORDER BY COUNT(*) DESC
		LIMIT 1
	);

	RETURN employee;
END;
$$


SELECT employee_with_most_transactions();




-- Create a function that will return a table with customer and their full address (address, district, city, country) by country 
CREATE OR REPLACE FUNCTION customers_in_country(country_name VARCHAR(50))
RETURNS TABLE (
	first_name VARCHAR,
	last_name VARCHAR,
	address VARCHAR,
	district VARCHAR,
	city VARCHAR,
	country VARCHAR
)
LANGUAGE plpgsql 
AS $$
BEGIN 
	RETURN QUERY
	SELECT c.first_name, c.last_name, a.address, a.district, ci.city, co.country 
	FROM customer c
	JOIN address a 
	ON c.address_id = a.address_id 
	JOIN city ci
	ON ci.city_id = a.city_id 
	JOIN country co
	ON co.country_id = ci.country_id 
	WHERE co.country = country_name;
END;
$$


SELECT *
FROM customers_in_country('United States');




SELECT *
FROM customers_in_country('United States')
WHERE district = 'Illinois';




DROP FUNCTION IF EXISTS count_actors_with_last_name(varchar, int4);



