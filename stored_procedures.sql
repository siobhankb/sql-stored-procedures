SELECT *
FROM customer;

SELECT *
FROM customer c 
WHERE loyalty_member = TRUE;


-- RESET ALL MEMBERS TO LOYALTY = FALSE
UPDATE customer 
SET loyalty_member = FALSE;



-- Create a procedure that will set customers who have spent at least $100 to loyalty_member 

-- subquery to find those members
SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id 
HAVING SUM(amount) >= 100;

-- Update Statement to set loyalty_member to true with subquery 
UPDATE customer 
SET loyalty_member = TRUE 
WHERE customer_id IN (
	SELECT customer_id
	FROM payment
	GROUP BY customer_id 
	HAVING SUM(amount) >= 100
);


-- Put above into a stored procedure

CREATE OR REPLACE PROCEDURE update_loyalty_status()
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE customer 
	SET loyalty_member = TRUE 
	WHERE customer_id IN (
		SELECT customer_id
		FROM payment
		GROUP BY customer_id 
		HAVING SUM(amount) >= 100
	);
END;
$$


SELECT *
FROM customer c 
WHERE loyalty_member = TRUE;


-- Execute a procedure - use the CALL keyword
CALL update_loyalty_status();

-- Check to see that procedure ran
SELECT *
FROM customer c 
WHERE loyalty_member = TRUE;



SELECT customer_id, SUM(amount) 
FROM payment
GROUP BY customer_id 
HAVING SUM(amount) BETWEEN 95 AND 100;


-- Add a new payment for user to push them over $100 total
INSERT INTO payment(
	customer_id, staff_id, rental_id, amount, payment_date 
)VALUES(554, 1, 2, 5, '2022-03-24');


SELECT *
FROM customer c 
WHERE c.customer_id = 554;


CALL update_loyalty_status();


SELECT *
FROM customer c 
WHERE c.customer_id = 554;



-- Create a procedure that takes in arguments
CREATE OR REPLACE PROCEDURE add_actor(
	first_name VARCHAR(50),
	last_name VARCHAR(50)
)
LANGUAGE plpgsql 
AS $$ 
BEGIN 
	INSERT INTO actor(first_name, last_name, last_update)
	VALUES(first_name, last_name, NOW());
END
$$


CALL add_actor('Robert', 'Pattinson');

SELECT *
FROM actor a 
WHERE last_name = 'Pattinson';



CREATE OR REPLACE FUNCTION add_actor_2(
	first_name VARCHAR(50),
	last_name VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql 
AS $$ 
BEGIN 
	INSERT INTO actor(first_name, last_name, last_update)
	VALUES(first_name, last_name, NOW());
END
$$

SELECT add_actor_2('Tom', 'Holland');

SELECT *
FROM actor a 
WHERE last_name = 'Holland';

DROP FUNCTION IF EXISTS add_actor_2;






