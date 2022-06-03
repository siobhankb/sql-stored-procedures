--stored FUNCTIONS return results
--stored PROCEDURES do NOT - they run an action that then returns control to user
--example is to UPDATE to reset values so that you can then change info
--instead of CREATE FUNCTION + SELECT <FUNCTION()>
--CREATE PROCEDURE + CALL <PRODECURE()>


--CREATE [ OR REPLACE ] PROCEDURE
--    name ( [ [ argmode ] [ argname ] argtype [ { DEFAULT | = } default_expr ] [, ...] ] )
--  { LANGUAGE lang_name
--    | TRANSFORM { FOR TYPE type_name } [, ... ]
--    | [ EXTERNAL ] SECURITY INVOKER | [ EXTERNAL ] SECURITY DEFINER
--    | SET configuration_parameter { TO value | = value | FROM CURRENT }
--    | AS 'definition'
--    | AS 'obj_file', 'link_symbol'
--    | sql_body
--  } ...



--find any customers who are currently loyalty_members
SELECT *
FROM customer
WHERE loyalty_member = TRUE;

-- reset all loyalty_members to FALSE
UPDATE customer 
SET loyalty_member = FALSE;



--Create a procedure that will set customers who have spent at least $100 to loyalty_members
--Query to get customer_ids of those who hve spent at least $100
SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id 
HAVING sum(amount) > 100

--UDATE statement to set loyalty_member to tru based on previous query
UPDATE customer
SET loyalty_member = TRUE 
WHERE customer_id IN (
	SELECT customer_id 
	FROM payment 
	GROUP BY customer_id 
	HAVING sum(amount) > 100
);

--put above update into stored prcedure
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
		HAVING sum(amount) > 100
	);
END;
$$

--execute PROCEDURE with CALL
CALL update_loyalty_status();

SELECT *
FROM customer
WHERE loyalty_member = TRUE;

--give extra credit to customers who are close to meeting $100 threshold
SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id 
HAVING sum(amount) BETWEEN 95 AND 100;

--Push one of the customers over the 100 threshold
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (554, 1, 2, 5, '2022-06-03 10:43:00');

--check that customer 554 has been updated
SELECT *
FROM customer c
WHERE customer_id = 554;

--call your procedure
CALL update_loyalty_status();

--check that 554 is now a loyalty_member
SELECT*
FROM customer c
WHERE customer_id = 554;


--create a PROCEDURE that takes in arguments
--thinking it's kind of annoying to have to retype all the column names when you want to update info
INSERT INTO actor(first_name, last_name, last_update)
VALUES ('Tom', 'Hanks', NOW())

--so make it a stored procedure:
CREATE OR REPLACE PROCEDURE add_actor(first_name VARCHAR(50), last_name VARCHAR(50))
LANGUAGE plpgsql
AS $$
BEGIN 
	INSERT INTO actor(first_name, last_name, last_update)
	VALUES (first_name, last_name, NOW());
END;
$$

--now add actor using procedure
CALL add_actor('Tom', 'Hanks');

SELECT *
FROM actor
WHERE last_name = 'Hanks';


CALL add_actor('Tom', 'Cruise');

SELECT *
FROM actor
WHERE first_name = 'Tom';

--to delete a procedure, use DROP
DROP PROCEDURE IF EXISTS add_actor();


