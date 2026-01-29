{{ 
  config(
    materialized='table'
  ) 
}}
-- dbt_model: fct_remote_spill_sample_data

WITH large_sales AS (

    SELECT
        ss_sold_date_sk,
        ss_customer_sk,
        ss_store_sk,
        ss_ext_sales_price
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.STORE_SALES
    -- Intentionally low-selectivity filter (forces wide scan)
    WHERE ss_sold_date_sk >= 2450816  -- ~1998

),

customers AS (

    SELECT
        c_customer_sk,
        c_current_country,
        c_birth_year
    FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER

),

joined_data AS (

    SELECT
        s.ss_sold_date_sk,
        c.c_current_country,
        c.c_birth_year,
        SUM(s.ss_ext_sales_price) AS total_revenue
    FROM large_sales s
    JOIN customers c
      ON s.ss_customer_sk = c.c_customer_sk
    GROUP BY
        s.ss_sold_date_sk,
        c.c_current_country,
        c.c_birth_year

)

SELECT *
FROM joined_data
-- Another low-selectivity predicate → poor pruning
WHERE c_current_country IN ('UNITED STATES', 'INDIA', 'CANADA', 'UNITED KINGDOM');
