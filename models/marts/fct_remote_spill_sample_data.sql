{{ 
  config(
    materialized='table'
  ) 
}}
-- dbt_model: fct_remote_spill_sample_data

-- PURPOSE:
-- Force REMOTE_SPILL by exhausting:
-- 1. Memory
-- 2. Local SSD
-- Result: disk-based shuffle → REMOTE_SPILL

WITH base_lineitem AS (

    SELECT
        l_orderkey,
        l_partkey,
        l_suppkey,
        l_extendedprice,
        l_quantity
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
    -- intentionally NO selective filter

),

base_orders AS (

    SELECT
        o_orderkey,
        o_custkey,
        o_totalprice
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS

),

exploded_join AS (

    SELECT
        o.o_custkey,
        l.l_partkey,
        l.l_suppkey,
        l.l_orderkey,
        l.l_extendedprice * l.l_quantity AS line_value
    FROM base_lineitem l
    JOIN base_orders o
      ON l.l_orderkey = o.o_orderkey

),

heavy_aggregation AS (

    SELECT
        o_custkey,
        l_partkey,
        l_suppkey,
        COUNT(*)                         AS row_cnt,
        SUM(line_value)                  AS total_value,
        AVG(line_value)                  AS avg_value,
        STDDEV(line_value)               AS stddev_value
    FROM exploded_join
    GROUP BY
        o_custkey,
        l_partkey,
        l_suppkey

)

SELECT *
FROM heavy_aggregation
ORDER BY
    o_custkey,
    l_partkey,
    total_value DESC