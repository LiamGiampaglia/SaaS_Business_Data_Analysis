-- We previously created and cleaned the SaaS_Subscriptions dataset, let's select that database for this Exploratory Data Analysis
Use SaaS_Subscriptions;

-- Let's begin by analysing the data for User and Subscription Behaviour

SELECT * 
FROM fulldata;

-- Lets see how many people signed up in each year

SELECT EXTRACT(YEAR FROM signup_date) AS signup_year, COUNT(DISTINCT user_id) AS user_count
FROM users
GROUP BY EXTRACT(YEAR FROM signup_date)
ORDER BY signup_year;

-- 2023 had 352 user signed up, 2024 had 486 and 2025 had 162


-- let's check which 3 months had largest sign ups

SELECT EXTRACT(YEAR FROM signup_date) AS signup_year, EXTRACT(MONTH FROM signup_date) AS signup_month, COUNT(DISTINCT user_id) AS user_count
FROM users
GROUP BY EXTRACT(YEAR FROM signup_date), EXTRACT(MONTH FROM signup_date)
ORDER BY user_count desc
Limit 3;

-- The 3 months with the largest sign ups were October 2023 with 55 users, followed by November 2023 with 53, followed by June 2024 with 49

-- Now we will check the 3 lowest months

SELECT EXTRACT(YEAR FROM signup_date) AS signup_year, EXTRACT(MONTH FROM signup_date) AS signup_month, COUNT(DISTINCT user_id) AS user_count
FROM users
GROUP BY EXTRACT(YEAR FROM signup_date), EXTRACT(MONTH FROM signup_date)
ORDER BY user_count asc
Limit 3;

-- The 3 lowest months in order were April 2023 with 13, September 2023 with 30 and May 2024 with 32

-- let's check how many users are active and how many have churned
select status, count(*)
from users
Group by Status;

-- 707 are still active and 293 have churned

SELECT *
FROM users;

-- Let's check acquisition channel for the most active users and most churned users

SELECT `status`, count(*) AS user_count, acquisition_channel
from users
GROUP BY `status`, acquisition_channel
ORDER BY `status`, count(*) DESC;

-- Organic has the most active users and is 3rd least churned, whereas Social Media has the least active users and most churned users

-- Let's check the percetage of active vs churned for each acquisiton channel

SELECT acquisition_channel, `status`, COUNT(*) AS user_count, ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY acquisition_channel), 2) AS percentage
FROM users
GROUP BY acquisition_channel, `status`
ORDER BY percentage DESC, acquisition_channel, `status`;


-- When looking at churn rates as % of total count, Paid ads has the highest active users at 74.21% are still active, followed by Organic with 72.38%, whereas Social Media has the highest churned percentage with 35.44% churned.

-- Let's move on and have a look into Revenue and Payment Insights
SELECT * 
FROM payments;

-- let's see which monts have the highest revenue

SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month, SUM(amount_paid_usd) AS total_revenue
FROM payments
GROUP BY month
ORDER BY total_revenue DESC
LIMIT 3;

-- The highest revenue months are February 2025, then March 2025 and then November 2024


-- Next we will see which are the highest revenue by Acquisition Channel

SELECT acquisition_channel, sum(amount_paid_usd) as total_revenue
FROM users AS u
JOIN payments AS p
ON u.user_id = p.user_id
GROUP BY acquisition_channel
ORDER BY total_revenue DESC;


-- Social Media and Partner ships have the highest revenue, whereas Paid Ads and Organic have the lowest revenue

-- Let's see revenue by Plan Type

SELECT pl.plan_name, SUM(p.amount_paid_usd) AS total_revenue
FROM payments AS p
JOIN subscriptions AS s 
	ON p.user_id = s.user_id
JOIN plans AS pl 
	ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name
ORDER BY total_revenue DESC;


-- The growth plan had the highest revenue, followed by enterprise plan, folowwed by starter plan


-- Let's see which platform has the highest revenue

SELECT platform, sum(amount_paid_usd) AS total_revenue
FROM users AS u
JOIN payments AS p
ON u.user_id = p.user_id
GROUP BY platform
ORDER BY total_revenue DESC;

-- Android has the highest, followed by Web and finally iOS