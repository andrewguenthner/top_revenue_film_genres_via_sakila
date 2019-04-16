USE sakila;
-- step 1a, list actors
SELECT first_name, last_name 
FROM actor;
-- step 1b, single column actors names in UPPERCASE
SELECT CONCAT(UPPER(first_name),' ',UPPER(last_name)) AS 'Actor Name'
FROM actor;
-- step 2a, find id & full name of all actors with first name "Joe"
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';
-- step 2b, find actors with 'GEN' in last name
SELECT CONCAT(first_name,' ',last_name) AS 'Name'
FROM actor
WHERE last_name LIKE '%GEN%';
-- step 2c, list actors with last name that contains 'll', ordered by last name, first name
SELECT CONCAT(first_name,' ',last_name) AS 'Name'
FROM actor
WHERE last_name LIKE '%LL%'
ORDER BY last_name, first_name;
-- step 2d, get country ID and country for Afghanistan, Bangladesh, China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');
-- step 3a, add a description column to the table 'actor' of type 'blob'
ALTER TABLE actor ADD COLUMN description BLOB AFTER last_name;
-- step 3b, delete this column on second thought ...
ALTER TABLE actor DROP description;
-- step 4a, list all actor last names and count of same
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name; 
-- step 4b, list last names shared by more than one actor and count of actors with said names
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;
-- step 4c, change 'GROUCHO WILLIAMS' record to 'HARPO WILLIAMS'
UPDATE actor SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- step 4d, undo fix but only by selecting on basis of first name ... (live a little dangerously!)
UPDATE actor SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';
-- step 5a, Hypothetical query to re-create address table
-- You can just pull this off the table info under 'DDL'... 
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
-- Step 6a, Display first name, last name, and address of each staff member
-- This will use US address style 
SELECT first_name, last_name, CONCAT(COALESCE(address,address2),
	    CHAR(13),CHAR(10),city,', ',district,' ',postal_code) AS full_address
FROM staff LEFT JOIN address ON (staff.address_id = address.address_id)
             JOIN city ON (address.city_id = city.city_id);
-- Step 6b, generate total sales by staff for August 2005 w/ implicit date conversion
SELECT CONCAT(first_name,' ',last_name) AS 'Name', SUM(amount) AS 'Sales'
FROM staff JOIN payment ON (staff.staff_id = payment.staff_id)
WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY staff.staff_id, first_name, last_name;
-- Step 6c, list each film and the number of actors in it
SELECT title, COUNT(actor_id)
FROM film_actor JOIN film ON (film_actor.film_id = film.film_id)
GROUP BY film.film_id;
-- Step 6d, how many copies of 'Hunchback Impossible' are in inventory?
SELECT COUNT(inventory_id)
FROM inventory JOIN film ON (inventory.film_id = film.film_id)
WHERE title = 'HUNCHBACK IMPOSSIBLE';
-- Step 6e, list all customers and how much they paid, order by last name
SELECT CONCAT(first_name,' ',last_name) AS 'Customer Name',SUM(amount) AS 'Total Paid'
FROM payment RIGHT JOIN customer ON (payment.customer_id = customer.customer_id)
GROUP BY customer.customer_id, first_name, last_name
ORDER BY last_name;
-- Step 7a,  list English language movies starting with K or Q, use subquery
SELECT title 
FROM film 
WHERE (language_id IN (SELECT language_id 
					  FROM `language` 
					  WHERE `name` = 'English'))
	AND (title LIKE 'K%' OR title LIKE 'Q%');
-- Step 7b:  List all actors from the film "Alone Trip"
SELECT CONCAT(first_name,' ',last_name)
FROM actor 
WHERE actor_id IN (SELECT actor_id 
                  FROM film_actor
				  WHERE film_id IN (SELECT film_id
                                    FROM film
                                    WHERE title = 'Alone Trip'));
-- Step 7c, return a list of name, email from all Canadian customers
SELECT CONCAT(first_name,' ',last_name) AS 'Customer', email
FROM customer JOIN address ON customer.address_id = address.address_id
              JOIN city ON address.city_id = city.city_id
WHERE country_id IN (SELECT country_id 
			        FROM country
                    WHERE country = 'Canada')
