{{ config(
    materialized='table'
) }}
-- dbt_model: fct_window_spill
-- expected_behavior: severe_local_and_remote_spill

SELECT
    l_orderkey,
    l_partkey,
    l_suppkey,
    l_linenumber,
    l_quantity,
    l_extendedprice,
    l_discount,
    l_tax,
    l_returnflag,
    l_linestatus,
    l_shipdate,
    l_commitdate,
    l_receiptdate,
    l_shipinstruct,
    l_shipmode,
    l_comment,
    SUM(l_extendedprice)
      OVER (
        PARTITION BY l_partkey
        ORDER BY l_comment
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      ) AS running_revenue
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM