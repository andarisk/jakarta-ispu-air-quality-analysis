# Data Cleaning Documentation

## Jakarta ISPU Air Quality Analysis (2016--2025)

### 1. Project overview

This project analyzes the Air Pollution Standard Index (Indeks Standar
Pencemaran Udara / ISPU) data for Jakarta from 2016 to 2025. The source
data was obtained from **Satu Data Jakarta** and consolidated into a
single dataset for data preparation, SQL analysis, and Power BI
visualization.

The data preparation stage was conducted manually in Microsoft Excel.
The resulting cleaned dataset was then used for the PostgreSQL analysis
and Power BI dashboard.

  Item                   Description
  ---------------------- ------------------------------------
  Data source            Satu Data Jakarta
  Observation period     1 January 2016 -- 30 November 2025
  Raw records            16,501
  Cleaned records        16,469
  Monitoring stations    DKI1--DKI5
  Cleaning tool          Microsoft Excel
  Final dataset format   CSV

### 2. Source data structure

The consolidated raw worksheet contains 14 columns:

`source_name`, `data_period`, `date`, `station_source`,
`station_location`, `pm25`, `pm10`, `so2`, `co`, `o3`, `no2`, `max`,
`critical`, and `category`.

The cleaned dataset retains these source fields and adds:

-   `category_revised`: an English-language ISPU category field derived
    from the `max` value using the ISPU category thresholds applied in
    this project.

The pollutant fields represent PM2.5, PM10, SO₂, CO, O₃, and NO₂. The
`max` field represents the maximum ISPU value recorded for an
observation, while `critical` identifies the parameter associated with
that maximum.

### 3. Data preparation workflow

The source files were consolidated into a raw worksheet before being
reviewed and cleaned in Microsoft Excel. The preparation process
included:

1.  Reviewing the consolidated records, column structure, date fields,
    reporting periods, station identifiers, and pollutant values.
2.  Checking missing values and unusual entries across the source data.
3.  Reviewing date and reporting-period inconsistencies against the
    source file and `data_period`.
4.  Standardizing station identifiers and station-location labels in the
    cleaned dataset.
5.  Normalizing selected missing-value and category representations.
6.  Creating `category_revised` for consistent English-language category
    reporting.
7.  Reviewing record counts, station coverage, and category
    distributions using Excel PivotTables and summary tables.

The cleaning was performed manually in Excel. The workbook included in
this repository is provided as supporting evidence of the raw data,
cleaned data, and Excel-based summaries. It should not be interpreted as
an automated or fully reproducible transformation script.

### 4. Documented data-quality issues and handling

#### 4.1 February 2022 date correction

Twenty-eight records in `ispu_jakarta_2022.xlsx` were associated with
reporting period `202202`, but their raw `date` values incorrectly
indicated February 2020.

The dates were corrected to February 2022 by cross-checking the
reporting period and source file. The 28 records were retained in the
cleaned dataset. The observation values were preserved, and the
critical-pollutant label `PM2,5` was standardized to `PM25` where
applicable.

#### 4.2 March 2020 station identifiers

The 155 records for reporting period `202003` in the 2020 source file
contained numeric values in `station_source` and blank values in
`station_location`, rather than the expected station identifiers and
labels.

The station information was standardized by reviewing patterns in the
corresponding-year Satu Data Jakarta reference data. The cleaned worksheet contains 31
records for each of DKI1--DKI5 for March 2020.

**Validation limitation:** the available workbook and reference file do
not independently establish a one-to-one source-to-station match for
every one of the 155 records. The station mapping is therefore documented as a pattern-based
identification, not as an independently verified row-by-row match. Station-level interpretation
for this period should be made with this limitation in mind.

#### 4.3 December 2022 overlapping reporting records

The raw consolidated worksheet contains two source representations for
reporting period `202212`:

-   `ispu_jakarta_2022.xlsx`: 31 records, one record per date.
-   `ispu_jakarta_2023.xlsx`: 155 records, representing five station
    records per date.

The cleaned dataset retains the 155-record, five-station representation
from the 2023 source and does not retain the 31-record representation
from the 2022 source.

These records are described as **overlapping reporting records with
different levels of granularity**, not as 31 confirmed exact duplicates.
The two representations were not assumed to be identical.

#### 4.4 One empty record dated outside its reporting period

One record from `ispu_jakarta_2024-2025.xlsx` had:

-   `data_period`: `202509`
-   `date`: `2025-10-01`
-   `station_source`: `DKI5`
-   `station_location`: `KEBON JERUK`
-   All pollutant, maximum ISPU, critical-pollutant, and category
    fields: blank

This record was not retained in the cleaned dataset. It was excluded
from the September 2025 reporting-period records because its observation
date fell on 1 October 2025 and its measurement fields were empty.

### 5. Missing values and category standardization

Missing values were retained as missing rather than being filled with
assumed measurements. In the cleaned dataset, missing values are
represented as `NULL` in the CSV/database context and blank cells in
Excel.

The cleaned dataset contains the following missing-value counts:

  Field                                     Missing records
  --------------------------------------- -----------------
  PM2.5                                               9,440
  PM10                                                  988
  SO₂                                                   530
  CO                                                    482
  O₃                                                    514
  NO₂                                                   604
  Maximum ISPU (`max`)                                  207
  Critical pollutant (`critical`)                       207
  Original category (`category`)                          1
  Revised category (`category_revised`)                   0

The original Indonesian category field was retained. A separate
`category_revised` field was added for consistent reporting:

  Original category    Revised category
  -------------------- ------------------
  BAIK                 Good
  SEDANG               Moderate
  TIDAK SEHAT          Unhealthy
  SANGAT TIDAK SEHAT   Very Unhealthy
  TIDAK ADA DATA       No Data

The category mapping follows the ISPU category scheme, which includes **Hazardous (BERBAHAYA)** as a recognized category. However, no records in this dataset fall into the Hazardous category.

The revised category distribution is:

  Revised category        Records
  ------------------ ------------
  Good                      2,667
  Moderate                 11,396
  Unhealthy                 2,154
  Very Unhealthy               45
  No Data                     207
  **Total**            **16,469**

### 6. Record-count reconciliation

The raw consolidated worksheet contains 16,501 records. The cleaned
dataset contains 16,469 records, resulting in a difference of 32
records.

  Reconciliation item                                                    Records
  ----------------------------------------------------------------- ------------
  Raw records                                                             16,501
  December 2022 lower-granularity representation not retained                -31
  Empty record dated 1 October 2025 under reporting period 202509             -1
  **Cleaned records**                                                 **16,469**

The 28 February 2022 records with incorrect raw dates are **not** part
of the 32-record difference; they were corrected and retained.

### 7. Coverage and reporting limitations

The cleaned dataset has five monitoring-station identifiers (DKI1--DKI5)
and covers 1 January 2016 through 30 November 2025. Important coverage
limitations include:

-   April 2018 is absent from the available source data.
-   December 2023 is absent from the available source data; the 2023
    source file contains observations from January through November
    2023, as well as December 2022 records.
-   The 2022 data has mixed reporting granularity. January--November
    2022 contains one selected-station record per date, while December
    2022 contains five station records per date.
-   PM2.5 is unavailable throughout 2016--2020 and remains incomplete in
    subsequent years.
-   Station-level comparisons across 2022 should be interpreted
    cautiously because the reporting coverage is uneven across stations
    and months.
-   The March 2020 station mapping is based on pattern review of the
    corresponding-year reference data and is not independently verified
    for every individual record.

### 8. Final dataset validation

The final cleaned dataset contains:

  Validation item                                            Result
  -------------------------------------- --------------------------
  Total records                                              16,469
  Unique observation dates                                    3,561
  Monitoring stations                                             5
  Duplicate date--station combinations                            0
  Date range                               2016-01-01 to 2025-11-30

The cleaned dataset was retained as the common input for subsequent
PostgreSQL analysis and Power BI reporting.

### 9. Files associated with this stage

The Excel analysis workbook contains the following worksheets:

-   `data_quality`: annual record coverage and pollutant completeness.
-   `station_coverage`: record counts by station and year.
-   `category_summary`: revised category distribution and comparison
    with original categories.
-   `ispu_jakarta_2016-2025`: consolidated raw records.
-   `ispu_jakarta_2016-2025_cleaned`: cleaned records, including
    `category_revised`.

The final CSV dataset is stored separately in the repository under
`Data/Processed/`.

------------------------------------------------------------------------

**Documentation note:** This document describes the cleaning decisions
and limitations that could be established from the available workbook,
source references, and the analyst's recollection of the manual Excel
process. Where row-level validation was not available, the limitation is
stated explicitly rather than presenting the transformation as fully
verified.
