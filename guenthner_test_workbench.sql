USE sakila;
-- step 1a, list actors
SELECT 
    first_name, last_name
FROM
    actor;
-- step 1b, single column actors names in UPPERCASE
SELECT 
    CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS 'Actor Name'
FROM
    actor;
-- step 2a, find id & full name of all actors with first name "Joe"
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';
-- step 2b, find actors with 'GEN' in last name
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Name'
FROM
    actor
WHERE
    last_name LIKE '%GEN%';
-- step 2c, list actors with last name that contains 'll', ordered by last name, first name
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Name'
FROM
    actor
WHERE
    last_name LIKE '%LL%'
ORDER BY last_name , first_name;
-- step 2d, get country ID and country for Afghanistan, Bangladesh, China
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');
-- step 3a, add a description column to the table 'actor' of type 'blob'
ALTER TABLE actor ADD COLUMN description BLOB AFTER last_name;
-- step 3b, delete this column on second thought ...
ALTER TABLE actor DROP description;
-- step 4a, list all actor last names and count of same
SELECT 
    last_name, COUNT(last_name)
FROM
    actor
GROUP BY last_name;
-- step 4b, list last names shared by more than one actor and count of actors with said names
SELECT 
    last_name, COUNT(last_name)
FROM
    actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;
-- step 4c, change 'GROUCHO WILLIAMS' record to 'HARPO WILLIAMS'
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';
-- step 4d, undo fix but only by selecting on basis of first name ... (live a little dangerously!)
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    first_name = 'HARPO';
-- step 5a, Hypothetical query to re-create address table
-- You can just pull this off the table info under 'DDL'... 
CREATE TABLE `address` (
    `address_id` SMALLINT(5) UNSIGNED NOT NULL AUTO_INCREMENT,
    `address` VARCHAR(50) NOT NULL,
    `address2` VARCHAR(50) DEFAULT NULL,
    `district` VARCHAR(20) NOT NULL,
    `city_id` SMALLINT(5) UNSIGNED NOT NULL,
    `postal_code` VARCHAR(10) DEFAULT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `location` GEOMETRY NOT NULL,
    `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`address_id`),
    KEY `idx_fk_city_id` (`city_id`),
    SPATIAL KEY `idx_location` ( `location` ),
    CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`)
        REFERENCES `city` (`city_id`)
        ON UPDATE CASCADE
)  ENGINE=INNODB AUTO_INCREMENT=606 DEFAULT CHARSET=UTF8;
-- Step 6a, Display first name, last name, and address of each staff member
-- This will use US address style 
SELECT 
    first_name,
    last_name,
    CONCAT(COALESCE(address, address2),
            CHAR(13),
            CHAR(10),
            city,
            ', ',
            district,
            ' ',
            postal_code) AS full_address
FROM
    staff
        LEFT JOIN
    address ON (staff.address_id = address.address_id)
        JOIN
    city ON (address.city_id = city.city_id);
-- Step 6b, generate total sales by staff for August 2005 w/ implicit date conversion
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Name',
    SUM(amount) AS 'Sales'
FROM
    staff
        JOIN
    payment ON (staff.staff_id = payment.staff_id)
WHERE
    payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY staff.staff_id , first_name , last_name;
-- Step 6c, list each film and the number of actors in it
SELECT 
    title, COUNT(actor_id)
FROM
    film_actor
        JOIN
    film ON (film_actor.film_id = film.film_id)
GROUP BY film.film_id;
-- Step 6d, how many copies of 'Hunchback Impossible' are in inventory?
SELECT 
    COUNT(inventory_id)
FROM
    inventory
        JOIN
    film ON (inventory.film_id = film.film_id)
WHERE
    title = 'HUNCHBACK IMPOSSIBLE';
-- Step 6e, list all customers and how much they paid, order by last name
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Customer Name',
    SUM(amount) AS 'Total Paid'
FROM
    payment
        RIGHT JOIN
    customer ON (payment.customer_id = customer.customer_id)
GROUP BY customer.customer_id , first_name , last_name
ORDER BY last_name;
-- Step 7a,  list English language movies starting with K or Q, use subquery
SELECT 
    title
FROM
    film
WHERE
    (language_id IN (SELECT 
            language_id
        FROM
            `language`
        WHERE
            `name` = 'English'))
        AND (title LIKE 'K%' OR title LIKE 'Q%');
-- Step 7b:  List all actors from the film "Alone Trip"
SELECT 
    CONCAT(first_name, ' ', last_name)
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));
-- Step 7c, return a list of name, email from all Canadian customers
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Customer', email
FROM
    customer
        JOIN
    address ON customer.address_id = address.address_id
        JOIN
    city ON address.city_id = city.city_id
WHERE
    country_id IN (SELECT 
            country_id
        FROM
            country
        WHERE
            country = 'Canada');
-- Step 7d, select all family films
SELECT 
    film.title
FROM
    film
        JOIN
    film_category ON film.film_id = film_category.film_id
WHERE
    category_id = (SELECT 
            category_id
        FROM
            category
        WHERE
            `name` = 'Family');
-- Step 7e,  list the movies in descending order of rental frequency
SELECT 
    film.title
FROM
    rental
        JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
        JOIN
    film ON inventory.film_id = film.film_id
GROUP BY film.film_id , film.title
ORDER BY COUNT(film.film_id) DESC;
 -- Step 7f, list the total sales by store (keep any uncategorized payments)
SELECT 
    store.store_id, city.city, country.country, SUM(amount)
FROM
    payment
        LEFT JOIN
    staff ON (payment.staff_id = staff.staff_id)
        LEFT JOIN
    store ON (staff.store_id = store.store_id)
        JOIN
    address ON (store.address_id = address.address_id)
        JOIN
    city ON (address.city_id = city.city_id)
        JOIN
    country ON (city.country_id = country.country_id)
GROUP BY store.store_id , city.city , country.country;
-- Step 7g, generate the city and country for each store id (already done in 7f
-- for readability of results)
SELECT 
    store.store_id, city.city, country.country
FROM
    store
        JOIN
    address ON (store.address_id = address.address_id)
        JOIN
    city ON (address.city_id = city.city_id)
        JOIN
    country ON (city.country_id = country.country_id)
GROUP BY store.store_id , city.city , country.country;
-- Step 7h, list the top 5 genres by revenue in descending order
-- Includes custom code to handle ties (note that RANK is not available)
-- Will list the "top 5" to include all items tied for #5
-- See the design doc for an easy-to-read breakdown of this query
SELECT 
    rank AS 'Revenue Rank',
    film_cat AS 'Genre',
    CONCAT('$',FORMAT(revenue,2)) AS 'Revenue from Genre'
FROM
    (SELECT 
        film_cat,
            revenue,
            IF(revenue = @last_amt, @cur_rank:=@cur_rank, @cur_rank:=@seq) AS rank,
            @seq:=@seq + 1,
            @last_amt:=revenue
    FROM
        (SELECT 
        category.`name` AS film_cat, SUM(amount) AS revenue
    FROM
        payment
    JOIN rental ON (payment.rental_id = rental.rental_id)
    JOIN inventory ON (rental.inventory_id = inventory.inventory_id)
    JOIN film ON (inventory.film_id = film.film_id)
    JOIN film_category ON (film.film_id = film_category.film_id)
    JOIN category ON (film_category.category_id = category.category_id)
    JOIN (SELECT @cur_rank:=1, @seq:=1, @last_amt:=NULL) rank_init
    GROUP BY category.`name`
    ORDER BY SUM(amount) DESC) ranked_revenue) ranking_table
WHERE
    rank <= 5;
-- Step 8a, create a view from the above table
-- First, make the query result into a persistent table, then create a view
CREATE TABLE top_5_genres AS SELECT rank AS 'Revenue Rank',
    film_cat AS 'Genre',
	CONCAT('$',FORMAT(revenue,2)) AS 'Revenue from Genre'
FROM
    (SELECT 
        film_cat,
            revenue,
            IF(revenue = @last_amt, @cur_rank:=@cur_rank, @cur_rank:=@seq) AS rank,
            @seq:=@seq + 1,
            @last_amt:=revenue
    FROM
        (SELECT 
        category.`name` AS film_cat, SUM(amount) AS revenue
    FROM
        payment
    JOIN rental ON (payment.rental_id = rental.rental_id)
    JOIN inventory ON (rental.inventory_id = inventory.inventory_id)
    JOIN film ON (inventory.film_id = film.film_id)
    JOIN film_category ON (film.film_id = film_category.film_id)
    JOIN category ON (film_category.category_id = category.category_id)
    JOIN (SELECT @cur_rank:=1, @seq:=1, @last_amt:=NULL) rank_init
    GROUP BY category.`name`
    ORDER BY SUM(amount) DESC) ranked_revenue) ranking_table
WHERE
    rank <= 5;
-- Now create the view (these steps can't be combined due to view restrictions)
CREATE VIEW v_top_5_genres AS
    SELECT 
        *
    FROM
        top_5_genres;
-- Step 8b, display the view
SELECT 
    *
FROM
    v_top_5_genres;
-- Step 8c, delete the view
DROP VIEW v_top_5_genres;