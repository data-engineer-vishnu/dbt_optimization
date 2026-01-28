{{ config(
    materialized='table'
) }}
-- dbt_model: fct_orders_join
-- expected_behavior: join_spill_on_small

SELECT
    o.o_orderkey,
    c.c_name,
    SUM(l.l_extendedprice) AS total_revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.ORDERS o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER c
    ON o.o_custkey = c.c_custkey
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.LINEITEM l
    ON o.o_orderkey = l.l_orderkey
GROUP BY
    o.o_orderkey,
    c.c_name
