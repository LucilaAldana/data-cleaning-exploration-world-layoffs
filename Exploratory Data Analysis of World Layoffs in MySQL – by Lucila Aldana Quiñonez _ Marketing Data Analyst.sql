-- EXPLORATORY DATA ANALYSIS OF WORLD LAYOFFS – by Lucila Aldana Quiñonez | Marketing Data Analyst

SELECT *
FROM world_layoffs_cleaned;

		-- Looking at the maximum number of employees laid off, and the maximum percentage of employees laid off:
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs_cleaned;

		-- Looking at the number of employees laid off in companies that laid off all of their employees, in descending order:
SELECT *
FROM world_layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

		-- Looking at the number of funds raised by companies that laid off all of their employees, in descending order:
SELECT *
FROM world_layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

		-- Looking at the sum of employees laid off in each company in the time period included in the dataset (more than one layoff occurred per company), in descending order:
SELECT company, SUM(total_laid_off)
FROM world_layoffs_cleaned
GROUP BY company
ORDER BY 2 DESC;

		-- Looking at the time period in the dataset:
SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs_cleaned;

		-- Looking at which industries had the most employees laid off during this time period, in descending order:
SELECT industry, SUM(total_laid_off)
FROM world_layoffs_cleaned
GROUP BY industry
ORDER BY 2 DESC;

		-- Looking at how many layoffs each company had during this time period, in descending order:
SELECT company, COUNT(*) AS times_layoffs
FROM world_layoffs_cleaned
GROUP BY company
ORDER BY times_layoffs DESC;

		-- Looking at which country had the most employees laid off during this time period, in descending order:
SELECT country, SUM(total_laid_off)
FROM world_layoffs_cleaned
GROUP BY country
ORDER BY 2 DESC;

		-- Looking at how many employees were laid off each year during this time period, in descending order:
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

		-- Looking at how many employees were laid off from each company stage, in descending order:
SELECT stage, SUM(total_laid_off)
FROM world_layoffs_cleaned
GROUP BY stage
ORDER BY 2 DESC;

		-- Looking at the sum of employess laid off each month during this time period:
SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off)
FROM world_layoffs_cleaned
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `year_month`
ORDER BY 1 ASC;

		-- Looking at the sum of employess laid off each month during this time period, with a rolling total:
WITH monthly_totals AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off) AS total_laid_off
    FROM world_layoffs_cleaned
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `year_month`
)
SELECT `year_month`, total_laid_off, SUM(total_laid_off) OVER (ORDER BY `year_month`) AS rolling_total
FROM monthly_totals
ORDER BY `year_month` ASC;

		-- Looking at the sum of employess laid off each month during this time period, with a rolling total, per country:
WITH monthly_totals AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(total_laid_off) AS total_laid_off
    FROM world_layoffs_cleaned
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
		AND country = 'United States'
    GROUP BY `year_month`
)
SELECT `year_month`, total_laid_off, SUM(total_laid_off) OVER (ORDER BY `year_month`) AS rolling_total
FROM monthly_totals
ORDER BY `year_month` ASC;

		-- Looking at how many employees were laid off by each company per year:
SELECT company, YEAR(`date`) AS year_laid_off, SUM(total_laid_off)
FROM world_layoffs_cleaned
GROUP BY company , year_laid_off
ORDER BY year_laid_off ASC;

		-- Looking at the top three layoffs of each year:
WITH company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) AS year_laid_off, SUM(total_laid_off)
FROM world_layoffs_cleaned
GROUP BY company , year_laid_off
), company_year_rank AS
(SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 3;