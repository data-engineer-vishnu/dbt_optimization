{{ config(materialized='table') }}

-- dbt_model: fct_lineitem_heavy
SELECT
    l_orderkey,
    l_extendedprice,
    l_comment
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.LINEITEM
ORDER BY l_comment
