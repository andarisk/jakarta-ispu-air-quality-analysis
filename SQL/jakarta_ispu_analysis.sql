-- =================================================
-- JAKARTA AIR QUALITY (ISPU) ANALYSIS | 2016-2025 
-- Database: jakarta_air_quality 
-- Table: public.air_quality

-- Important data notes:
-- - 2022 has mixed granularity: Jan-Nov has one selected-station record per date; 
--   Dec has five station records per date.
-- - 2018 is missing April; 2023 and 2025 are missing December.
-- - PM2.5 is unavailable for 2016-2020 and has additional gaps later.
-- - Record counts are not automatically equivalent to unique days.
-- =================================================

----------------------------------------------------
-- Q01: Total Records
-- Objective: Check the number of imported rows
----------------------------------------------------

SELECT COUNT(*) AS total_rows 
FROM public.air_quality;

----------------------------------------------------
-- Q02: Duplicate Check
-- Objective: Identify duplicate date-station pairs
----------------------------------------------------

SELECT date, station_source, COUNT(*) AS duplicate_count
FROM public.air_quality
GROUP BY 1,2
HAVING COUNT(*) > 1
ORDER BY 1,2;

----------------------------------------------------
-- Q03: Yearly Data Coverage
-- Objective: Inspect date coverage and average rows per date
----------------------------------------------------

SELECT
EXTRACT (YEAR FROM date) AS year,
COUNT(DISTINCT date) AS unique_date,
COUNT(DISTINCT station_source) AS distinct_station,
ROUND(COUNT(*)::NUMERIC / NULLIF(COUNT(DISTINCT date),0),2) AS records_per_date
FROM public.air_quality
GROUP BY 1
ORDER BY 1;

----------------------------------------------------
-- Q04: Missing Values by Parameter
-- Objective: Count missing values and calculate their percentages
----------------------------------------------------

WITH missing AS(
SELECT
COUNT(*) AS total_records, 
COUNT(*) FILTER (WHERE pm25 IS NULL) AS pm25_missing,
COUNT(*) FILTER (WHERE pm10 IS NULL) AS pm10_missing,
COUNT(*) FILTER (WHERE so2 IS NULL) AS so2_missing,
COUNT(*) FILTER (WHERE co IS NULL) AS co_missing,
COUNT(*) FILTER (WHERE o3 IS NULL) AS o3_missing,
COUNT(*) FILTER (WHERE no2 IS NULL) AS no2_missing,
COUNT(*) FILTER (WHERE max IS NULL) AS max_missing
FROM public.air_quality
)
SELECT
total_records,
pm25_missing,
ROUND(pm25_missing::NUMERIC / total_records*100, 2) AS pm25_missing_percentage,
pm10_missing,
ROUND(pm10_missing::NUMERIC / total_records*100, 2) AS pm10_missing_percentage,
so2_missing,
ROUND(so2_missing::NUMERIC / total_records*100, 2) AS so2_missing_percentage,
co_missing,
ROUND(co_missing::NUMERIC / total_records*100, 2) AS co_missing_percentage,
o3_missing,
ROUND(o3_missing::NUMERIC / total_records*100, 2) AS o3_missing_percentage,
no2_missing,
ROUND(no2_missing::NUMERIC / total_records*100, 2) AS no2_missing_percentage,
max_missing,
ROUND(max_missing::NUMERIC / total_records*100, 2) AS max_missing_percentage
FROM missing;

----------------------------------------------------
-- Q05: Overall Category Distribution
-- Objective: Count records by revised category
----------------------------------------------------

SELECT category_revised, 
COUNT (date) AS total_records
FROM public.air_quality
GROUP BY 1
ORDER BY 2 DESC;

----------------------------------------------------
-- Q06: Category Distribution by Year
-- Objective: Count records by year and revised category
----------------------------------------------------

SELECT 
EXTRACT(YEAR FROM date) AS year, 
category_revised, 
COUNT(date) AS total_records
FROM public.air_quality
GROUP BY 1,2
ORDER BY 1 ASC, 3 DESC;

----------------------------------------------------
-- Q07: Year Over Year Change in Unhealthy Records
-- Objective: Compare yearly counts of records categorized Unhealthy
-- Caveat: 2022 is not directly comparable because of mixed granularity
--         (one record/date Jan-Nov, five records/date Dec)
----------------------------------------------------

WITH yearly AS(
SELECT 
EXTRACT(YEAR FROM date) AS year,
COUNT(*) AS unhealthy_records 
FROM public.air_quality
WHERE category_revised = 'Unhealthy'
GROUP BY 1
)
SELECT year, 
unhealthy_records,
LAG(unhealthy_records) OVER(ORDER BY year) AS previous_year,
unhealthy_records - LAG(unhealthy_records) OVER(ORDER BY year) AS change_from_previous
FROM yearly
ORDER BY 1;

----------------------------------------------------
-- Q08: Unhealthy Records by Station
-- Objective: Compare station-level counts without the 2022 period 
--            where only one selected station record exists per date
-- Caveat: This excludes 11 months of 2022; 
--         interpret station totals as counts within the available, 
--         filtered observations
----------------------------------------------------

SELECT station_source, 
station_location, 
COUNT(*) AS unhealthy_records
FROM public.air_quality
WHERE date NOT BETWEEN '2022-01-01' AND '2022-11-30'
AND category_revised = 'Unhealthy'
GROUP BY 1,2
ORDER BY 3 DESC;

----------------------------------------------------
-- Q09: Critical Pollutant Distribution by Year
-- Objective: Count records by year and critical pollutant
----------------------------------------------------

SELECT 
EXTRACT(YEAR FROM date) AS year, 
critical, 
COUNT(date) AS total_records
FROM public.air_quality
WHERE critical IS NOT NULL
GROUP BY 1, 2
ORDER BY 1 ASC, 3 DESC;

----------------------------------------------------
-- Q10: Monthly Average PM2.5
-- Objective: Calculate monthly average PM2.5 for each year-month period
----------------------------------------------------

SELECT to_char(date, 'YYYY-MM') AS year_month, 
ROUND(AVG(pm25),2) AS average_pm25,
COUNT(pm25) AS valid_pm25_records
FROM public.air_quality
WHERE pm25 IS NOT NULL
GROUP BY 1
ORDER BY 1;

----------------------------------------------------
-- Q11: Highest Monthly Average PM2.5 Per Year
-- Objective: Identify the month with the highest observed
--            monthly average PM2.5 in each year.
----------------------------------------------------

WITH monthly AS (
SELECT
EXTRACT(YEAR FROM date) AS year,
EXTRACT(MONTH FROM date) AS month,
AVG(pm25) AS avg_pm25,
COUNT(pm25) AS valid_pm25_records
FROM public.air_quality
WHERE pm25 IS NOT NULL
GROUP BY 1, 2
),
ranked AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY year
ORDER BY avg_pm25 DESC
) AS rn
FROM monthly
)
SELECT year, month, ROUND(avg_pm25, 2) AS avg_pm25, valid_pm25_records
FROM ranked
WHERE rn = 1
ORDER BY 1;

----------------------------------------------------
-- Q12: Record Coverage by Station
-- Objective: Inspect first date, last date, 
--            and number of records available for each station.
----------------------------------------------------

SELECT station_source, 
station_location, 
MIN(date) AS start, 
MAX(date) AS finish, 
COUNT(date) AS total_records
FROM public.air_quality
GROUP BY 1,2
ORDER BY 1;