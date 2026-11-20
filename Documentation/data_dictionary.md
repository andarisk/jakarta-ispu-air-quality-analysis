# Data Dictionary
## Jakarta ISPU Air Quality Analysis (2016–2025)

This document describes the fields in the cleaned Jakarta ISPU dataset used for PostgreSQL analysis and the Power BI dashboard.

### Dataset overview

| Attribute | Description |
|---|---|
| Dataset | Jakarta ISPU Air Quality Dataset |
| Source | Satu Data Jakarta |
| Observation period | 1 January 2016 – 30 November 2025 |
| Number of records | 16,469 |
| Number of fields | 15 |
| Monitoring stations | 5 (DKI1–DKI5) |
| File format | CSV |
| Date field format in CSV | `DD/MM/YYYY` |
| Reporting-period field format | `YYYYMM` |

### Field definitions

| No. | Field | PostgreSQL data type | Description |
|---:|---|---|---|
| 1 | `source_name` | `VARCHAR(100)` | Name of the source file from which the record originated. Used to retain source-file lineage. |
| 2 | `data_period` | `VARCHAR(10)` | Reporting period associated with the record, retained as text in `YYYYMM` format (for example, `202201` represents January 2022). |
| 3 | `date` | `DATE` | Observation date for the record. Dates in the CSV are represented in `DD/MM/YYYY` format. |
| 4 | `station_source` | `VARCHAR(20)` | Monitoring-station identifier used in the source data (DKI1–DKI5). |
| 5 | `station_location` | `VARCHAR(150)` | Name of the monitoring-station location associated with the station identifier. |
| 6 | `pm25` | `NUMERIC` | ISPU component value for particulate matter with a diameter of 2.5 micrometres or less (PM2.5), as provided in the source dataset. |
| 7 | `pm10` | `NUMERIC` | ISPU component value for particulate matter with a diameter of 10 micrometres or less (PM10), as provided in the source dataset. |
| 8 | `so2` | `NUMERIC` | ISPU component value for sulfur dioxide (SO₂), as provided in the source dataset. |
| 9 | `co` | `NUMERIC` | ISPU component value for carbon monoxide (CO), as provided in the source dataset. |
| 10 | `o3` | `NUMERIC` | ISPU component value for ozone (O₃), as provided in the source dataset. |
| 11 | `no2` | `NUMERIC` | ISPU component value for nitrogen dioxide (NO₂), as provided in the source dataset. |
| 12 | `max` | `NUMERIC` | Maximum ISPU value among the reported pollutant component values for the observation. |
| 13 | `critical` | `VARCHAR(50)` | Pollutant parameter identified as the critical parameter associated with the maximum ISPU value. |
| 14 | `category` | `VARCHAR(50)` | Original ISPU category label retained from the source data, in Indonesian. |
| 15 | `category_revised` | `VARCHAR(50)` | Standardized English-language ISPU category derived from the `max` value using the category thresholds applied in this project. |

### Monitoring-station reference

| Station ID | Station location |
|---|---|
| DKI1 | Bundaran HI |
| DKI2 | Kelapa Gading |
| DKI3 | Jagakarsa |
| DKI4 | Lubang Buaya |
| DKI5 | Kebon Jeruk |

### ISPU category reference

The ISPU classification scheme includes the following categories. The `Hazardous` category is part of the classification scheme, although no observations in this cleaned dataset are assigned to it.

| Indonesian category | English label | Records in `category_revised` |
|---|---|---:|
| BAIK | Good | 2,667 |
| SEDANG | Moderate | 11,396 |
| TIDAK SEHAT | Unhealthy | 2,154 |
| SANGAT TIDAK SEHAT | Very Unhealthy | 45 |
| BERBAHAYA | Hazardous | 0 |
| TIDAK ADA DATA | No Data | 207 |
| **Total** |  | **16,469** |

`No Data` is used as a data-availability label, rather than an air-quality severity category.

### Missing values

Missing values are retained as missing and are not imputed. In the CSV, missing numeric or text values are represented as empty fields; when imported into PostgreSQL, they are treated as `NULL`.

| Field | Missing records |
|---|---:|
| `pm25` | 9,440 |
| `pm10` | 988 |
| `so2` | 530 |
| `co` | 482 |
| `o3` | 514 |
| `no2` | 604 |
| `max` | 207 |
| `critical` | 207 |
| `category` | 1 |
| `category_revised` | 0 |

### Important interpretation notes

1. The pollutant fields (`pm25`, `pm10`, `so2`, `co`, `o3`, and `no2`) refer to the ISPU component values provided in the source dataset. They should not be interpreted as raw ambient pollutant concentrations unless the source metadata explicitly establishes that unit and measurement basis.
2. `max` is the maximum reported ISPU component value, while `critical` identifies the corresponding critical pollutant parameter.
3. `category` preserves the original source category. `category_revised` is a separate standardized category field used in the analysis; the two fields may differ because the revised category is derived from `max`.
4. The March 2020 station identifiers were standardized through pattern review of corresponding-year Satu Data Jakarta reference data. A one-to-one independent validation for all 155 records was not established; refer to `data_cleaning_documentation.md` for this limitation.
5. Reporting coverage is uneven in some periods. In particular, the 2022 dataset has mixed reporting granularity, and station-level comparisons should be interpreted cautiously. See the data cleaning documentation for further details.

### Related files

- `data/processed/jakarta_ispu_2016_2025_cleaned.csv` — cleaned dataset described by this dictionary.
- `excel/jakarta_ispu_excel_analysis.xlsx` — Excel workbook containing raw data, cleaned data, and supporting summaries.
- `documentation/data_cleaning_documentation.md` — data preparation workflow, data-quality issues, record reconciliation, and limitations.
