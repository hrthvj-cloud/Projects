                           -- CHURN AND RETENTION ANALYSIS

CREATE DATABASE cust_churn_project;

USE cust_churn_project;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  age INT,
  gender VARCHAR(10),
  tenure INT,
  usage_frequency INT,
  support_calls INT,
  payment_delay INT,
  subscription_type VARCHAR(20),
  contract_length VARCHAR(20),
  total_spend INT,
  last_interaction INT,
  churn TINYINT
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "C:/Users/dell/OneDrive/Documents/customer_churn_dataset-testing-master.csv" 
INTO TABLE customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

SELECT *
FROM CUSTOMERS
GROUP BY customer_id
HAVING COUNT(*) > 1; # No Duplicates 

-- creating view customer segments based on age, tenure,delay_group,calls_group

CREATE VIEW customers_clean AS
SELECT *,
  CASE WHEN age <= 25 THEN '18-25' WHEN age <= 35 THEN '26-35'
       WHEN age <= 45 THEN '36-45' WHEN age <= 55 THEN '46-55' ELSE '56-65' END AS age_group,
  CASE WHEN tenure <= 12 THEN '0-12' WHEN tenure <= 24 THEN '13-24'
       WHEN tenure <= 36 THEN '25-36' WHEN tenure <= 48 THEN '37-48' ELSE '49-60' END AS tenure_group,
  CASE WHEN payment_delay <= 10 THEN '0-10 days' WHEN payment_delay <= 20 THEN '11-20 days'
       ELSE '21-30 days' END AS delay_group,
  CASE WHEN support_calls <= 2 THEN '0-2' WHEN support_calls <= 5 THEN '3-5'
       ELSE '6+' END AS calls_group
FROM customers;

-- CALCULATION OF CHURN AND RETENTION RATE PCT 

SELECT age_group, COUNT(*) AS Total_customers,
SUM(churn) as churned, 
ROUND(100 * AVG(churn), 2) as Churn_pct, 
ROUND(100* (1- AVG(churn)), 2) as retention_pct
from customers_clean;
  
-- CHURN AND RETENTION PCT BASED ON AGE GROUP

SELECT age_group, COUNT(*) AS Total_customers,
SUM(churn) as churned, 
ROUND(100 * AVG(churn), 2) as Churn_pct, 
ROUND(100* (1- AVG(churn)), 2) as retention_pct
from customers_clean
GROUP BY age_group;

SELECT tenure_group, COUNT(*) AS Total_customers,
SUM(churn) as churned, 
ROUND(100 * AVG(churn), 2) as Churn_pct, 
ROUND(100* (1- AVG(churn)), 2) as retention_pct
from customers_clean
GROUP BY tenure_group
order by tenure_group asc;




