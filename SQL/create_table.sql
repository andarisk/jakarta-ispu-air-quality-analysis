-- =========================================================
-- JAKARTA AIR QUALITY (ISPU) ANALYSIS | 2016-2025
-- Database: jakarta_air_quality
-- Schema: public
-- Table: public.air_quality
--
-- Purpose:
-- Create the table structure for the cleaned Jakarta ISPU dataset.
--
-- Notes:
-- - The table contains 15 columns matching the cleaned CSV.
-- =========================================================

CREATE TABLE IF NOT EXISTS public.air_quality(
source_name VARCHAR(100),
data_period VARCHAR(10),
date DATE,
station_source VARCHAR(20),
station_location VARCHAR(150),
pm25 NUMERIC,
pm10 NUMERIC,
so2 NUMERIC,
co NUMERIC,
o3 NUMERIC,
no2 NUMERIC,
max NUMERIC,
critical VARCHAR(50),
category VARCHAR(50),
category_revised VARCHAR(50)
);