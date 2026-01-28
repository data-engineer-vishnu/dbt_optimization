{{ config(
    materialized='table'
) }}
-- dbt_model: fct_under_provisioned_join
-- expected_behavior: severe_join_spill

SELECT
    o.o_orderkey,
    o.o_orderdate,
    c.c_name,
    c.c_comment,
    c.c_address,
    c.c_phone,
    SUM(l.l_extendedprice) AS total_revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.CUSTOMER c
  ON o.o_custkey = c.c_custkey
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM l
  ON o.o_orderkey = l.l_orderkey
GROUP BY
    o.o_orderkey,
    o.o_orderdate,
    c.c_name,
    c.c_comment,
    c.c_address,
    c.c_phone
ORDER BY c.c_comment