USE hr_attrition;


LOAD DATA LOCAL INFILE 'C:/Users/dell/OneDrive/Documents/hr_attrition_data.csv' 
INTO TABLE hr_attrition 
FIELDS TERMINATED BY ',' 
IGNORE 1 ROWS;

SELECT
    COUNT(*)                                   AS total_rows,
    COUNT(*) - COUNT(Department)               AS missing_department,
    COUNT(*) - COUNT(MonthlyIncome)             AS missing_income,
    COUNT(*) - COUNT(Attrition)                 AS missing_attrition
FROM hr_attrition;

SELECT EmployeeID, COUNT(*)
FROM hr_attrition
GROUP BY EmployeeID
HAVING COUNT(*) > 1;

-- there are no missing / duplicate values

select * 
from hr_attrition 

-- overall attrition rate 
select count(*)  as total_employee, 
sum(case when attrition = 'yes' then 1 else 0 end) as employee_left,
round(100.0 * sum(case when attrition = 'yes' then 1 else 0 end)/ count(*),2) as attrition_rate_per
from hr_attrition;

-- --attrition rate by dept 

select department, 
count(*) as headcount, 
sum(case when attrition = 'yes' then 1 else 0 end) as left_count,
round(100.0 * sum(case when attrition = 'yes' then 1 else 0 end)/ count(*),2) as attrition_rate_per
from hr_attrition
group by department
order by attrition_rate_per desc;

-- Within departments, which specific roles are highest-risk?
select department, 
	   JobRole,
       count(*) as headcount, 
       round(100.0 * sum(case when attrition = 'yes' then 1 else 0 end)/ count(*),2) as attrition_rate_per
from hr_attrition
group by department, JobRole
having count(*) >=5
order by attrition_rate_per desc;


-- --Does regularly working overtime increase the likelihood of leaving? 
select overtime,
       count(*) as headcount, 
       round(100.0 * sum(case when attrition = 'yes' then 1 else 0 end)/ count(*),2) as attrition_rate_per
from hr_attrition
group by overtime
order by attrition_rate_per desc;

-- If the 'Yes' group's attrition rate is noticeably higher than the 'No' group's, 
-- that's a strong, actionable signal — HR could investigate workload balancing for high-overtime roles

-- Is pay a driver of attrition? Compare average income between the two groups
SELECT
    Attrition,
    COUNT(*)                          AS headcount,
    ROUND(AVG(MonthlyIncome), 0)      AS avg_monthly_income,
    MIN(MonthlyIncome)                AS min_income,
    MAX(MonthlyIncome)                AS max_income
FROM hr_attrition
GROUP BY Attrition;	

with income_by_group as (
     select attrition, 
     avg(monthlyincome) as avg_income
from hr_attrition
group by attrition
)
SELECT
    MAX(CASE WHEN Attrition = 'No'  THEN avg_income END) AS avg_income_stayed,
    MAX(CASE WHEN Attrition = 'Yes' THEN avg_income END) AS avg_income_left,
    ROUND(
        100.0 * (
            MAX(CASE WHEN Attrition = 'No' THEN avg_income END) -
            MAX(CASE WHEN Attrition = 'Yes' THEN avg_income END)
        ) / MAX(CASE WHEN Attrition = 'No' THEN avg_income END),
        2
    ) AS pct_income_gap
FROM income_by_group;

-- attrition by tenure bucket
SELECT
    CASE
        WHEN YearsAtCompany < 2  THEN '0-1 years'
        WHEN YearsAtCompany < 5  THEN '2-4 years'
        WHEN YearsAtCompany < 10 THEN '5-9 years'
        ELSE '10+ years'
    END AS tenure_bucket,
    COUNT(*) AS headcount,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS attrition_rate_pct
FROM hr_attrition
GROUP BY tenure_bucket
ORDER BY MIN(YearsAtCompany);

-- Ranking dept names with windows function
SELECT 
    Department,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct,
    RANK() OVER (
        ORDER BY SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) DESC
    ) AS attrition_rank
FROM hr_attrition
GROUP BY Department
ORDER BY attrition_rank;

-- create view as a virtual table 
-- Once your key queries are finalized, wrap the core logic in a VIEW so BI tools (Power BI, Tableau) 
-- or teammates can query it like a table without repeating your logic.

CREATE VIEW vw_department_attrition_summary AS
SELECT
    Department,
    COUNT(*)                                              AS headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)    AS employees_left,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    )                                                     AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 0)                          AS avg_monthly_income,
    ROUND(AVG(JobSatisfaction), 2)                        AS avg_job_satisfaction
FROM hr_attrition
GROUP BY Department;


       
 






