select * from layoffs_2025;

DESCRIBE layoffs_2025;

set sql_safe_updates = 0;

UPDATE layoffs_2025 
SET total_laid_off = NULL 
WHERE total_laid_off = '' OR total_laid_off = 'NULL' OR TRIM(total_laid_off) = '';

set sql_safe_updates = 1;

ALTER TABLE layoffs_2025 
MODIFY COLUMN total_laid_off INT;

set sql_safe_updates = 0;

UPDATE layoffs_2025 
SET percentage_laid_off = NULL 
WHERE percentage_laid_off = '' OR percentage_laid_off = 'NULL' OR TRIM(percentage_laid_off) = '';

set sql_safe_updates = 1;

alter table layoffs_2025
modify column percentage_laid_off int;

select date
from layoffs_2025;

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_2025 
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_2025 
MODIFY COLUMN date DATE;

describe layoffs_2025

UPDATE layoffs_2025
set funds_raised = NULL 
where funds_raised = '' or funds_raised = 'NULL' or trim(funds_raised) = '';

ALTER TABLE layoffs_2025
MODIFY COLUMN funds_raised INT; 

UPDATE layoffs_2025
SET date_added = STR_TO_DATE(date_added,'%m/%d/%Y')

ALTER TABLE layoffs_2025
modify column date_added date;

describe layoffs_2025;

-- We have succesfully changed datatypes 

select distinct company 
from layoffs_2025;

select trim(company)
from layoffs_2025
order by 1;

update layoffs_2025
set company = trim(company);

select * from layoffs_2025;

select distinct location 
from layoffs_2025
order by 1;

update layoffs_2025
set location = null 
where location = '' or location = 'NULL' OR TRIM(location) = '';

select * from layoffs_2025;

select distinct industry 
from layoffs_2025
order by 1

update layoffs_2025 
set industry = NULL
where industry = '';

update layoffs_2025
set stage = null
where stage = '' or stage = 'Unknown';

select distinct country 
from layoffs_2025
order by 1;

update layoffs_2025
set country = null
where country = '';

select * from layoffs_2025;

-- Data cleaned 

DELETE FROM layoffs_2025 
where total_laid_off = NULL and percentage_laid_off = NULL;

-- if we dont have the total_laid_off and % laid off then the records are useless for layoff

-- Maybe we can calculate the the average laid off based on the company 

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_2025 t1
left join (
select industry, round(avg(total_laid_off)) as avg_laid
from layoffs_2025
where total_laid_off is not null
group by industry
)t2 on t1.industry = t2.industry 
set t1.total_laid_off = t2.avg_laid
where t1.total_laid_off is null;

SELECT industry, total_laid_off 
FROM layoffs_2025;

-- successfully imputed null values in total_laid_off. 

SELECT * 
FROM layoffs_2025;

-- we cannot calculate the percentage_laid_off as we do not have any other data like total employees 

-- Top 5 industries hit by laid_off

select industry,sum(total_laid_off) as sum_laid
from layoffs_2025
group by industry
order by sum(total_laid_off) DESC
LIMIT 5;

-- OTHER, RETAIL,HARDWARE,CONSUMER,TRANSPORTATION

-- Monthly layoff volume 

select date_format(date,'%Y-%m') as layoff_month, sum(total_laid_off) as sum_laid
from layoffs_2025
group by layoff_month
order by layoff_month;

-- Yearly layoff volume

select date_format(date,'%Y') as layoff_year, sum(total_laid_off) as sum_laid
from layoffs_2025
group by layoff_year
order by layoff_year desc;

-- funds_raised by country 
select * from layoffs_2025;

select country, sum(funds_raised) as Total_funds_raised
from layoffs_2025
group by country;

-- Top 10 countries by funds_raised
select country, sum(funds_raised) as Total_funds_raised
from layoffs_2025
group by country
order by  Total_funds_raised desc
limit 10;

-- Years which has raised more funds_raised 

select date_format(date,'%Y') as year_fund, sum(funds_raised) as Total_funds_raised
from layoffs_2025
group by year_fund
order by Total_funds_raised desc

