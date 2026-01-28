{{ config(materialized='table') }}

-- dbt_model: agg_revenue_optimal
-- expected_behavior: well_sized

SELECT
    l_partkey,
    SUM(l_extendedprice) AS total_revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.LINEITEM
GROUP BY l_partkey
