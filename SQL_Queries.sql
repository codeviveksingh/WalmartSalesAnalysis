CREATE DATABASE IF NOT EXISTS walmartSales;


-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- Data cleaning
SELECT
	*
FROM sales;

-- Add the time_of_day column

alter table sales 
add column `Time_of_day` varchar (20);

SELECT 
    time,
    (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS `time_of_day`
FROM
    sales;

set Sql_safe_updates = 0;

UPDATE sales 
SET 
    time_of_day = (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END);

-- Add Day_name column 

alter table sales
add column day_name varchar(20);

UPDATE sales 
SET 
    day_name = DAYNAME(date);

UPDATE sales 
SET 
    date = STR_TO_DATE(date, '%m/%d/%Y');

UPDATE sales 
SET 
    day_name = DAYNAME(date);
SELECT 
    *
FROM
    sales;

SELECT 
    date, MONTHNAME(date) AS month_name
FROM
    sales;

alter table sales
add column month varchar(20);

UPDATE sales 
SET 
    month = MONTHNAME(date);

---------------------------
--------- Generic ---------
---------------------------

--- How many unique city does data have ?

select distinct city from sales;

--- In which city is each Branch ?

select distinct city, branch from sales;



-- How many unique product line does the data have ?

SELECT DISTINCT
    `product line`
FROM
    sales;

SELECT 
    *
FROM
    sales;
SELECT 
    COUNT(`invoice id`) AS total, `product line`
FROM
    sales
GROUP BY `product line`
ORDER BY total DESC;

-- What is the most selling Product Line
SELECT 
    SUM(quantity) AS qty, `product line`
FROM
    sales
GROUP BY `product line`
ORDER BY qty DESC;
 
 
 -- what is the total revenue by month 

SELECT 
    SUM(`total`) AS Total_Revenue, month
FROM
    sales
GROUP BY month
ORDER BY Total_Revenue DESC;

-- What month had largest COGS 


SELECT 
    SUM(cogs) AS cogs, month
FROM
    sales
GROUP BY month
ORDER BY cogs DESC;



-- What Product line had the largest revenue ?

SELECT 
    SUM(total) AS total, `product line`
FROM
    sales
GROUP BY `product line`
ORDER BY total DESC;

-- what is the city had the largest revenue ?

SELECT 
    SUM(total) AS total, city, branch
FROM
    sales
GROUP BY city , branch
ORDER BY total DESC;

-- what product line had the largest VAT ?

SELECT 
    AVG(`tax 5%`) AS VAT, `product line`
FROM
    sales
GROUP BY `product line`
ORDER BY VAT DESC;

-- fetch each product line and add a column to those Product
-- line showing "good", "Bad". good if its grater than avg sales


SELECT 
    `product line`,
    CASE
        WHEN
            AVG(quantity) > (SELECT 
                    AVG(quantity)
                FROM
                    sales)
        THEN
            'Good'
        ELSE 'Bad'
    END AS Remark
FROM
    sales
GROUP BY `product line`;

 -- List all branches where the average quantity of products sold per branch is higher than the overall average quantity of products sold across all branches.
 
 
SELECT 
    branch, AVG(quantity)
FROM
    sales
GROUP BY branch
HAVING AVG(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales);
 
 -- What is the most common product line by gender
 
SELECT 
    Gender, `product line`, COUNT(gender) AS total_cnt
FROM
    sales
GROUP BY gender , `product line`
ORDER BY total_cnt DESC;
 
 -- What is the average rating of each product line
 
SELECT 
    ROUND(AVG(rating), 2), `product line`
FROM
    sales
GROUP BY `product line`;
 -- ------------------------------------------------------------------
-- ------------------------------------------------------------------- 
SELECT DISTINCT
    `customer type`
FROM
    sales;
 
 -- How many unique payment methods does the data have?
 
SELECT DISTINCT
    payment
FROM
    sales;
 
 -- What is the most common customer type?
 
SELECT 
    COUNT(*) AS count, `customer type`
FROM
    sales
GROUP BY `customer type`;
 
 -- Which customer type buys the most?
 
SELECT 
    `customer type`, COUNT(*) AS count
FROM
    sales
GROUP BY `customer type`
ORDER BY count DESC;
 
 -- What is the gender of most of the customers?
 
SELECT 
    COUNT(*) AS count, gender
FROM
    sales
GROUP BY gender;
 
 -- What is the gender distribution per branch?
 
SELECT 
    branch, COUNT(gender), gender
FROM
    sales
GROUP BY gender , branch
ORDER BY branch ASC;
 
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.
	
SELECT 
    ROUND(AVG(rating), 2) AS avg_rating, time_of_day
FROM
    sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter

SELECT 
    branch, time_of_day, ROUND(AVG(rating), 2) AS avg_rating
FROM
    sales
GROUP BY branch , time_of_day
ORDER BY avg_rating DESC;

-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

SELECT 
    day_name, ROUND(AVG(rating), 2) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Sun, Mon and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?

SELECT 
    branch, day_name, ROUND(AVG(rating), 2) AS avg_rating
FROM
    sales
GROUP BY branch , day_name
ORDER BY avg_rating DESC;
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

SELECT 
    time_of_day, COUNT(*) AS count
FROM
    sales
WHERE
    day_name = 'sunday'
GROUP BY time_of_day
ORDER BY count DESC;
 
-- Evenings experience most sales, the stores are 
-- filled during the evening hours 

SELECT 
    `customer type`, ROUND(SUM(total), 2) AS total
FROM
    sales
GROUP BY `customer type`
ORDER BY total DESC;

-- Which city has the largest tax/VAT payable?

SELECT 
    city, ROUND(AVG(`tax 5%`), 2) AS tax_payable
FROM
    sales
GROUP BY city;

-- Which customer type pays the most in VAT?

SELECT 
    `customer type`, ROUND(AVG(`tax 5%`), 2) AS avg_tax_paid
FROM
    sales
GROUP BY `customer type`;

-- ----------------------END-----------------------------
