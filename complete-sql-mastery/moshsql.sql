USE sql_store;

--
--
--
SELECT last_name,
       points,
       (points + 10) * 100 AS 'discount factor' -- math order
FROM customers;

--
--
--
SELECT DISTINCT state -- unique values
FROM customers;

--
-- 
--
SELECT *
FROM customers
WHERE state <> 'va';
-- != "VA"

--
--
--
SELECT *
FROM orders
WHERE order_date >= '2018-01-01'
  AND order_date <= '2018-12-31';

--
--
--
SELECT *
FROM customers
WHERE NOT (birth_date > '1990-01-01')
   OR (points > 1000 AND state = 'VA');
-- AND evaluates first, with higher precedence

--
--
--
SELECT *
FROM order_items
WHERE order_id = 6
  AND (quantity * unit_price) > 30;

--
-- IN
--
SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72);

--
-- BETWEEN
--
SELECT *
FROM customers
WHERE points BETWEEN 1000 AND 3000;
-- WHERE points >= 1000 AND points <= 3000;

--
-- LIKE - it's like contain
--
-- % is for any number of charater
-- _ is for single character
--
SELECT *
FROM customers c
WHERE c.last_name LIKE 'b%'; -- starts with b and % means any number of characters

SELECT *
FROM customers c
WHERE c.last_name LIKE 'b%'; -- ends with b

SELECT *
FROM customers c
WHERE c.last_name LIKE 'b____y'; -- _ means one character

SELECT *
FROM customers
WHERE address LIKE '%trail%'
   OR address LIKE '%avenue%' AND phone LIKE '%9';
-- phone numbers ends with 9

--
--
--
SELECT *
FROM customers AS c
WHERE c.address LIKE '%trail%'
   OR c.address LIKE '%avenue%' AND c.phone LIKE '%9';
-- phone numbers ends with 9


--
-- REGEXP
--
-- LIKE '%PATTERN%' same as REGEXP 'PATTERN'
-- ^ begin of a string
-- $ end of a string
-- | logical or, for multiple search patterns
-- [gim]e any one of characters in [] brackets -> 'ge' 'ie' 'me'
-- [a-z]e any one from a to z alphabet
-- 
SELECT *
FROM customers AS c
     -- WHERE c.last_name LIKE '%ield%'
     -- WHERE c.last_name REGEXP 'ield' -- c.last_name LIKE '%ield%'
     -- WHERE c.last_name REGEXP 'ield$' -- last name with 'ield' on the end
     -- WHERE c.last_name REGEXP 'ield$|^mac|rose'
     -- WHERE c.last_name REGEXP '[gim]e'
WHERE c.last_name REGEXP '[a-f]e';

--
-- NULL
--

SELECT *
FROM customers
WHERE phone IS NOT NULL;

--
-- ORDER BY
--

SELECT order_id, quantity, unit_price, quantity * unit_price AS total_price
FROM order_items AS oi
WHERE oi.order_id = 2
ORDER BY total_price DESC;

--
-- LIMIT
--

SELECT *
FROM customers
LIMIT 6, 3;
-- 6 is offset (skip), 3 is records limit


# ##############################################################################
# Joins
# ##############################################################################

--
-- INNER JOIN
--
-- with JOINS we combine columns
-- INNER word is optional
--
SELECT order_id, orders.customer_id, first_name, last_name
FROM orders
     JOIN customers ON orders.customer_id = customers.customer_id;
-- return a record if this condition is true

--
-- JOINING ACROSS DATABASES
--
-- prefix database in query if it's not you are actually using, as we use sql_store; here
--
SELECT *
FROM order_items                 oi
     JOIN sql_inventory.products p ON oi.product_id = p.product_id;

--
-- SELF JOINS
--
-- we have to prefix table and columns
--
USE sql_hr;
SELECT e.employee_id, e.first_name, m.first_name manager
FROM employees      e
     JOIN employees m ON e.reports_to = m.employee_id;

--
-- JOINING MULTIPLE TABLES
--
USE sql_store;
SELECT order_id, order_date, first_name, last_name, name status
FROM orders              o
     JOIN customers      c ON o.customer_id = c.customer_id
     JOIN order_statuses os ON o.status = os.order_status_id;


USE sql_invoicing;
SELECT date, invoice_id, amount, c.name, pm.name payment_method
FROM payments
     JOIN clients         c ON payments.client_id = c.client_id
     JOIN payment_methods pm ON payments.payment_method = pm.payment_method_id;

--
-- COMPOUND JOIN CONDITION
--
-- composite primary key contains more than one column
-- multiple conditions to join to tables
--
SELECT *
FROM order_items           oi
     JOIN order_item_notes oin ON oi.order_id = oin.order_id AND oi.product_id = oin.product_id;

--
-- IMPLICIT JOIN SYNTAX
--
SELECT *
FROM orders         o
     JOIN customers c ON o.customer_id = c.customer_id;

-- implicit JOIN syntax
SELECT *
FROM orders    o,
     customers c
WHERE o.customer_id = c.customer_id;


--
-- OUTER JOINS
--
-- OUTER word is optional, LEFT or RIGHT OUTER JOIN
--

-- here we see all customers; left table
SELECT c.customer_id, first_name, order_id
FROM customers        c
     LEFT JOIN orders o ON c.customer_id = o.customer_id -- all customers records + orders if condition is true
ORDER BY c.customer_id;

-- here we see all orders; right table
SELECT c.customer_id, first_name, order_id
FROM customers         c
     RIGHT JOIN orders o ON c.customer_id = o.customer_id -- all orders records + customers if condition is true
ORDER BY c.customer_id;

SELECT p.product_id, name, quantity
FROM products              p
     LEFT JOIN order_items oi ON p.product_id = oi.product_id;

--
-- OUTER JOIN BETWEEN MULTIPLE TABLES
-- best practice aware to use RIGHT JOIN
--

SELECT c.customer_id, first_name, order_id, name AS shipper
FROM customers          c
     LEFT JOIN orders   o ON c.customer_id = o.customer_id
     LEFT JOIN shippers s ON o.shipper_id = s.shipper_id
ORDER BY c.customer_id;

SELECT order_date, order_id, first_name AS customer, s.name AS shipper, os.name AS status
FROM orders                   o
     JOIN      customers      c ON c.customer_id = o.customer_id
     LEFT JOIN shippers       s ON o.shipper_id = s.shipper_id
     JOIN      order_statuses os ON o.status = os.order_status_id
ORDER BY status;

--
-- SELF OUTER JOIN
--
USE sql_hr;
SELECT e.employee_id, e.first_name, m.first_name manager
FROM employees           e
     LEFT JOIN employees m ON e.reports_to = m.employee_id;

--
-- NATURAL JOINS
--
-- JOIN on columns with same name
-- avoid it, because DB have to guess join
--
SELECT order_id, first_name
FROM orders                 o
     NATURAL JOIN customers c;

--
-- USING CLAUSE
--
-- if tables got columns with same name
--
SELECT order_id, first_name, name AS shipper
FROM orders              o
     JOIN      customers c USING (customer_id) -- ON o.customer_id = c.customer_id
     LEFT JOIN shippers USING (shipper_id);

SELECT *
FROM order_items           oi
     JOIN order_item_notes oin
            # ON oi.order_id = oin.order_Id AND oi.product_id = oin.product_id
          USING (order_id, product_id);

USE sql_invoicing;
SELECT date, c.name AS client, amount, pm.name
FROM payments             p
     JOIN clients         c USING (client_id)
     JOIN payment_methods pm ON p.payment_method = pm.payment_method_id;


--
-- CROSS JOINS
--
-- for tables with sizes or colors
--
SELECT first_name AS customer, p.name AS product
FROM customers           c
     CROSS JOIN products p
ORDER BY product_id;

-- same CROSS JOIN result
SELECT first_name AS customer, p.name AS product
FROM customers c,
     products  p
ORDER BY product_id;


--
-- UNIONS
--
-- with JOINS we combine columns, with UNIONS combine rows
-- number of columns u get returnd should be equal
--

SELECT order_id, order_date, 'Active' AS status
FROM orders
WHERE order_date >= '2019-01-01' -- NO SEMICOLON
UNION
SELECT order_id, order_date, 'Archive' AS status
FROM orders
WHERE order_date < '2019-01-01';

-- example how UNION combines rows
SELECT first_name
FROM customers
UNION
SELECT name
FROM shippers;

# SELECT  first_name FROM archived_orders
# UNION
# SELECT name FROM orders;

SELECT customer_id, first_name, points, 'Bronze' AS type
FROM customers
WHERE points < 2000
UNION
SELECT customer_id, first_name, points, 'Silver'
FROM customers
WHERE points BETWEEN 2000 AND 3000
UNION
SELECT customer_id, first_name, points, 'Gold' AS type
FROM customers
WHERE points > 3000
ORDER BY first_name;



# ##############################################################################
# Inserting, Updating, and Deleting Data
# ##############################################################################


