CREATE DATABASE PIZZAHUT;
USE PIZZAHUT;

CREATE TABLE ORDERS(
ORDER_ID INT NOT NULL,
ORDER_DATE DATE NOT NULL,
ORDER_TIME TIME NOT NULL,
PRIMARY KEY (ORDER_ID));

CREATE TABLE ORDER_DETAILS(
ORDER_DETAILS_ID INT NOT NULL,
ORDER_ID INT NOT NULL,
PIZZA_ID TEXT NOT NULL,
QUANTITY INT NOT NULL,
PRIMARY KEY (ORDER_DETAILS_ID));

-- QUESTIONS:
-- 1) Retrieve the total number of orders placed?
SELECT * FROM ORDERS;
SELECT COUNT(ORDER_ID) AS TOTAL_ORDERS FROM ORDERS;

-- 2) Calculate the total revenue generated from pizza sales?
SELECT
ROUND(SUM(ORDER_DETAILS.QUANTITY*PIZZAS.PRICE),2) AS TOTAL_REVENUE
FROM ORDER_DETAILS JOIN PIZZAS
ON ORDER_DETAILS.PIZZA_ID=PIZZAS.PIZZA_ID;

-- 3) Identify the highest-priced pizza?
SELECT
PIZZA_TYPES.NAME, PIZZAS.PRICE
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
ORDER BY PIZZAS.PRICE DESC LIMIT 1;

-- 4) Identify the most common pizza size ordered?
SELECT
PIZZAS.SIZE, COUNT(ORDER_DETAILS.ORDER_DETAILS_ID) AS COUNT_OF_ORDER
FROM PIZZAS JOIN ORDER_DETAILS
ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
GROUP BY PIZZAS.SIZE ORDER BY COUNT_OF_ORDER DESC LIMIT 1;

-- 5) List the top 5 most ordered pizza types along with their quantities?
SELECT
PIZZA_TYPES.NAME, SUM(ORDER_DETAILS.QUANTITY) AS TOTAL_QUANTITY
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
JOIN ORDER_DETAILS 
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.NAME ORDER BY TOTAL_QUANTITY DESC LIMIT 5;

-- 6) Join the necessary tables to find the total quantity of each pizza category ordered?
SELECT 
PIZZA_TYPES.CATEGORY,
SUM(ORDER_DETAILS.QUANTITY) AS QUANTITY
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
JOIN ORDER_DETAILS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.CATEGORY ORDER BY QUANTITY DESC;

-- 7) Determine the distribution of orders by hour of the day?
SELECT HOUR(ORDER_TIME) AS HOUR, COUNT(ORDER_ID) AS ORDER_COUNT 
FROM ORDERS GROUP BY HOUR;

-- 8) Join relevant tables to find the category-wise distribution of pizzas?
SELECT CATEGORY, COUNT(NAME) AS COUNT FROM PIZZA_TYPES
GROUP BY CATEGORY;

-- 9) Group the orders by date and calculate the average number of pizzas ordered per day?
SELECT ROUND(AVG(QUANTITY),0) FROM
(SELECT 
ORDERS.ORDER_DATE, SUM(ORDER_DETAILS.QUANTITY) AS QUANTITY
FROM ORDERS JOIN ORDER_DETAILS
ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
GROUP BY ORDERS.ORDER_DATE) AS ORDER_QUANTITY ;

-- 10) Determine the top 3 most ordered pizza types based on revenue?
SELECT
PIZZA_TYPES.NAME, SUM(ORDER_DETAILS.QUANTITY*PIZZAS.PRICE) AS REVENUE
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
JOIN ORDER_DETAILS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.NAME ORDER BY REVENUE DESC LIMIT 3;

-- 11) Calculate the percentage contribution of each pizza type to total revenue?
SELECT
PIZZA_TYPES.CATEGORY, ROUND(SUM(ORDER_DETAILS.QUANTITY*PIZZAS.PRICE) / (SELECT
ROUND(SUM(ORDER_DETAILS.QUANTITY*PIZZAS.PRICE),2) AS TOTAL_REVENUE
FROM ORDER_DETAILS JOIN PIZZAS
ON ORDER_DETAILS.PIZZA_ID=PIZZAS.PIZZA_ID) *100,2) AS REVENUE
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
JOIN ORDER_DETAILS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.CATEGORY ORDER BY REVENUE DESC;

-- 12) Analyze the cumulative revenue generated over time?
SELECT ORDER_DATE, SUM(REVENUE) OVER(ORDER BY ORDER_DATE) AS CUMULATIVE_REVENUE
FROM
(SELECT ORDERS.ORDER_DATE,
SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE
FROM ORDER_DETAILS JOIN PIZZAS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
JOIN ORDERS
ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
GROUP BY ORDERS.ORDER_DATE) AS SALES;

-- 13) Determine the top 3 most ordered pizza types based on revenue for each pizza category?
SELECT CATEGORY, NAME, REVENUE FROM

(SELECT CATEGORY, NAME, REVENUE, RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RANKING
FROM

(SELECT PIZZA_TYPES.CATEGORY, PIZZA_TYPES.NAME,
SUM((ORDER_DETAILS.QUANTITY) * PIZZAS.PRICE) AS REVENUE
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
JOIN ORDER_DETAILS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.CATEGORY, PIZZA_TYPES.NAME) AS SALES_A) AS SALES_B
WHERE RANKING<=3;

