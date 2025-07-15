-- Create the database, import data via 'Table Data Import Wizard'

CREATE DATABASE SaaS_Subscriptions;


-- check if the tables imported correctly

SELECT * 
FROM payments;

SELECT * 
FROM plans;

SELECT * 
FROM subscriptions;

SELECT * 
FROM users;


-- join all tables together

SELECT 
	p.user_id, 
	s.plan_id, 
	p.payment_date, 
    p.amount_paid_usd, 
    p.paid_on_time, 
    s.subscription_date, 
    s.status as subscription_status, 
    monthly_revenue_usd, 
    monthly_price_usd, 
    signup_date, 
    acquisition_channel, 
    platform, 
    u.status as user_status
From 
	payments as p
JOIN subscriptions as s 
	on p.user_id = s.user_id
JOIN plans as pl 
	on pl.plan_id = s.plan_id
JOIN users as u 
	on u.user_id = p.user_id;


-- create new table and insert the joined tables

CREATE TABLE `FullData` (
  `user_id` INT,
  `plan_id` INT,
  `payment_date` TEXT,
  `amount_paid_usd` INT,
  `paid_on_time` TEXT,
  `subscription_date` TEXT,
  `subscription_status` TEXT,
  `monthly_revenue_usd` INT,
  `monthly_price_usd` INT,
  `signup_date` TEXT,
  `acquisition_channel` TEXT,
  `platform` TEXT,
  `user_status` TEXT
);

-- insert the joined tables into one big table

INSERT INTO FullData (
	user_id, 
    plan_id, 
    payment_date, 
    amount_paid_usd, 
    paid_on_time, 
    subscription_date, 
    subscription_status, 
    monthly_revenue_usd, 
    monthly_price_usd, 
    signup_date, 
    acquisition_channel, 
    platform, 
    user_status)
SELECT 
	p.user_id, 
	s.plan_id, 
    p.payment_date, 
    p.amount_paid_usd, 
    p.paid_on_time, 
    s.subscription_date, 
    s.status AS subscription_status, 
    monthly_revenue_usd, 
    monthly_price_usd, 
    signup_date, 
    acquisition_channel, 
    platform, 
    u.status AS user_status
FROM payments AS p
JOIN subscriptions AS s 
	ON p.user_id = s.user_id
JOIN plans AS pl 
	ON s.plan_id = pl.plan_id
JOIN users AS u 
	ON p.user_id = u.user_id;


-- Check that the table has worked

SELECT * 
FROM FullData;


-- Let begin the cleaning process in the following order
-- 1. Remove Any Duplicates
-- 2. Standarise the Data
-- 3. Deal with any Null Values or Blanks
-- 4. Remove any unnecessary columns

-- 1. Remove Any Duplicates
-- To check for duplicates I will use row numbers to find help duplicate values

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY
	user_id, 
    plan_id, 
    payment_date, 
    amount_paid_usd, 
    paid_on_time, 
    subscription_date, 
    subscription_status, 
    monthly_revenue_usd, 
    monthly_price_usd, 
    signup_date, 
    acquisition_channel, 
    platform, 
    user_status) AS row_num 
FROM FullData;



-- Using a CTE I will locate the specific duplicates

WITH duplicate_cte AS (SELECT *, 
ROW_NUMBER() OVER(PARTITION BY
	user_id, 
    plan_id, 
    payment_date, 
    amount_paid_usd, 
    paid_on_time, 
    subscription_date, 
    subscription_status, 
    monthly_revenue_usd, 
    monthly_price_usd, 
    signup_date, 
    acquisition_channel, 
    platform, 
    user_status) AS row_num 
FROM FullData)
SELECT * FROM duplicate_cte WHERE row_num > 1;

-- There are 0 duplicates

-- Now that we have identified 0 duplicates, it's time to move on next stage of data cleaning which is...
-- 2. Standardise the Data
-- Date columns were a text format, so we need to change to DATE format


UPDATE FullData
SET 
	payment_date = CAST(payment_date AS DATE), 
    subscription_date = CAST(subscription_date AS DATE), 
    signup_date = CAST(signup_date AS DATE)
WHERE 
	payment_date IS NOT NULL 
    OR subscription_date IS NOT NULL 
    OR signup_date IS NOT NULL;


-- Then alter the table so that it changes to DATE and refresh the table to see if the column has changed from text to DATE


ALTER TABLE FullData
MODIFY COLUMN `payment_date` DATE,
MODIFY COLUMN `subscription_date` DATE,
MODIFY COLUMN `signup_date` DATE;

-- Check that the table has worked

SELECT * 
FROM FullData;

-- Now the data has been standaised, let's move on next stage of data cleaning which is...
-- 3. Deal with any Null Values or Blanks
-- Let's check if we have any NULLs or blank values

-- user id column checks
SELECT *
FROM FullData
WHERE user_id IS NULL;

SELECT *
FROM FullData
WHERE user_id = ' ';

-- 0 blanks or nulls

-- plan id column checks
SELECT *
FROM FullData
WHERE plan_id IS NULL;

SELECT *
FROM FullData
WHERE plan_id = ' ';

-- 0 blanks or nulls

-- payment_date column checks
SELECT *
FROM FullData
WHERE payment_date IS NULL;

SELECT *
FROM FullData
WHERE payment_date = ' ';

-- 0 blanks or nulls

-- payment_date column checks
SELECT *
FROM FullData
WHERE amount_paid_usd IS NULL;

SELECT *
FROM FullData
WHERE amount_paid_usd = ' ';

-- 0 nulls, 3029 blanks but there are 0, likely indictating free, therefore we don't need to delete

-- paid_on_time column checks
SELECT *
FROM FullData
WHERE paid_on_time IS NULL;

SELECT *
FROM FullData
WHERE paid_on_time = ' ';

-- 0 blanks or nulls

-- subscription_date column checks
SELECT *
FROM FullData
WHERE subscription_date IS NULL;

SELECT *
FROM FullData
WHERE subscription_date = ' ';

-- 0 blanks or nulls

-- subscription_status column checks
SELECT *
FROM FullData
WHERE subscription_status IS NULL;

SELECT *
FROM FullData
WHERE subscription_status = ' ';

-- 0 blanks or nulls

-- monthly_revenue_usd column checks
SELECT *
FROM FullData
WHERE monthly_revenue_usd IS NULL;

SELECT *
FROM FullData
WHERE monthly_revenue_usd = ' ';

-- 0 blanks or nulls

-- monthly_price_usd column checks
SELECT *
FROM FullData
WHERE monthly_price_usd IS NULL;

SELECT *
FROM FullData
WHERE monthly_price_usd = ' ';

-- 0 blanks or nulls

-- signup_date column checks
SELECT *
FROM FullData
WHERE signup_date IS NULL;

SELECT *
FROM FullData
WHERE signup_date = ' ';

-- 0 blanks or nulls

-- acquisition_channel column checks
SELECT *
FROM FullData
WHERE acquisition_channel IS NULL;

SELECT *
FROM FullData
WHERE acquisition_channel = ' ';

-- 0 blanks or nulls

-- platform column checks
SELECT *
FROM FullData
WHERE platform IS NULL;

SELECT *
FROM FullData
WHERE platform = ' ';

-- 0 blanks or nulls

-- user_status column checks
SELECT *
FROM FullData
WHERE user_status IS NULL;

SELECT *
FROM FullData
WHERE user_status = ' ';

-- 0 blanks or nulls


-- Now the data has been checked for NULLs and Blanks, let's move on next stage of data cleaning which is...
-- 4. Remove any unnecessary columns

-- Let's check our table again to see if any columns are irrelevant for data analysis

SELECT *
FROM fulldata;

-- all columns appear to be useful for analysis