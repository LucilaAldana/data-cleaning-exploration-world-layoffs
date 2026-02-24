-- DATA CLEANING OF WORLD LAYOFFS – by Lucila Aldana Quiñonez | Marketing Data Analyst

		-- Creating a database:
CREATE SCHEMA world_layoffs;

		-- Importing data table from a .csv file and becoming familiar with it:
SELECT *
FROM world_layoffs;

		-- Renaming the table as raw data to keep it as the original data:
RENAME TABLE world_layoffs TO world_layoffs_rawdata;

		-- Creating a table to make a copy of the raw data table:
CREATE TABLE world_layoffs_staging LIKE world_layoffs_rawdata;

		-- Inserting the data from the raw data table to start working:
INSERT world_layoffs_staging
SELECT *
FROM world_layoffs_rawdata;


	-- 1. Remove Duplicates
		-- Grouping identical rows and numerating them:
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM world_layoffs_staging;

		-- Creating a CTE where only the duplicate rows are shown:
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

		-- Crating a copy of the late table with a new column containing the duplicate rows identifier:
CREATE TABLE `world_layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

		-- Inserting the values into the new table:
INSERT INTO world_layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs_staging;

		-- Deleting the duplicate rows:
DELETE
FROM world_layoffs_staging2
WHERE row_num > 1;


	-- 2. Standarize the Data: Finding issues in the data and fixing it
		-- Deleting blank spaces in the right and left side of the 'company' column rows:
SELECT DISTINCT company
FROM world_layoffs_staging2;

UPDATE world_layoffs_staging2 
SET company = TRIM(company);

		-- Standarizing industry names:
SELECT DISTINCT industry
FROM world_layoffs_staging2
ORDER BY 1;

UPDATE world_layoffs_staging2 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

		-- Correcting location names:
SELECT DISTINCT location
FROM world_layoffs_staging2
ORDER BY 1;

UPDATE world_layoffs_staging2 
SET location = 'Dusseldorf'
WHERE location LIKE '%sseldorf';

UPDATE world_layoffs_staging2 
SET location = 'Florianopolis'
WHERE location LIKE 'Florian%';

UPDATE world_layoffs_staging2 
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

UPDATE world_layoffs_staging2 
SET location = 'San Francisco Bay Area'
WHERE location LIKE 'SF%';

		-- Correcting country names:
SELECT DISTINCT country
FROM world_layoffs_staging2
ORDER BY 1;

UPDATE world_layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

		-- Correcting date column:
UPDATE world_layoffs_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE world_layoffs_staging2
MODIFY COLUMN `date` DATE;


	-- 3. Null Values or Blank Values
		-- Identifying null or blank values:
SELECT *
FROM world_layoffs_staging2
WHERE industry IS NULL
OR industry = '';

			-- Setting all blank values to null values to simplify the updating of the values:
UPDATE world_layoffs_staging2 
SET industry = NULL
WHERE industry = '';
   
			-- Updating the values (only those that have a reference in the data set, a "populated row"):
UPDATE world_layoffs_staging2 t1
JOIN world_layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


	-- 4. Remove Unnecessary or Irrelevant Columns and Rows
		-- Identifying columns and rows to delete:
SELECT *
FROM world_layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

		-- Deleting rows that do not contain any total_laid_off nor percentage_laid_off values. Those do not provide information about layoffs to the analysis.
DELETE
FROM world_layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

		-- Deleting the duplicate identifier column created at the beggining of the data cleaning.
ALTER TABLE world_layoffs_staging2
DROP COLUMN row_num;

	-- RENAMING CLEAN TABLE:

		-- Creating a copy of the clean table to rename it with a proper name and use it for further analysis:
CREATE TABLE world_layoffs_cleaned LIKE world_layoffs_staging2;

		-- Inserting the data from the clean table to the new properly named table, to start working on exploratory analysis:
INSERT world_layoffs_cleaned
SELECT *
FROM world_layoffs_staging2;

SELECT *
FROM world_layoffs_cleaned;
