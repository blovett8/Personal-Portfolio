-- EXPLORATORY DATA ANALYSIS PROJECT following Data Cleaning

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Shows the companies that were completely laid off by how many funds were raised in descending order
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Shows how many employees were laid off for each company from highest to lowest
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Date range for the Data
SELECT MIN(`date`) AS Latest_Date, MAX(`date`) AS Earliest_Date
FROM layoffs_staging2;

-- Shows total employees laid off by industry from highest to lowest
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Shows total employees laid off by country from highest to lowest
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Shows total employees laid off by date starting with the most recent date (a bit tedious)
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

-- Shows total employees laid off by the year from most recent to latest date
SELECT YEAR(`date`) AS laid_off_year, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY laid_off_year
ORDER BY 1 DESC;

-- Shows total employees laid off according to the stage of the company from most laid off to least
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- ROLLING SUM FOR TOTAL LAYOFFS

-- First, I want to see how it groups it by the month for each year
SELECT SUBSTRING(`date`, 1, 7) AS layoff_month, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY layoff_month
ORDER BY 1 ASC;

-- Create a CTE for Rolling Total by each month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS layoff_month, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY layoff_month
ORDER BY 1 ASC
)
SELECT layoff_month, total_off, SUM(total_off) OVER(ORDER BY layoff_month) AS rolling_total
FROM Rolling_Total;
-- END OF ROLLING TOTAL SCENARIO

-- How much did each company lay off by the year?
-- First, I'll look at how much each company laid off overall
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Look at layoffs by the year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- CREATE A CTE TO SHOW THE RANK OF LAYOFFS BY YEAR FOR EACH COMPANY AND THEN SHOW THE TOP 5 AT THE END
-- This CTE can also be used to look at other columns like stage and industry
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
-- END OF Company Year Ranking CTE