{{ config(
    materialized='table'
) }}
-- dbt_model: dim_customers_sort
-- expected_behavior: sort_spill

SELECT
    *
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.CUSTOMER
ORDER BY c_comment, c_address, c_name