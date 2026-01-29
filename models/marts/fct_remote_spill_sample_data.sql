{{ 
  config(
    materialized='table'
  ) 
}}
-- dbt_model: fct_remote_spill_sample_data

-- Purpose:
-- Force REMOTE_SPILL using TPCH_SF100 by:
-- 1. Large table scan
-- 2. Join before aggregation
-- 3. Low selectivity filters
-- 4. No clustering
-- 5. Small warehouse

WITH large_lineitems AS (

    SELECT
        l_orderkey,
        l_partkey,
        l_suppkey,
        l_extendedprice,
        l_shipdate
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM
    -- BAD filter: scans most partitions
    WHERE l_shipdate >= DATE '1992-01-01'

),

large_orders AS (

    SELECT
        o_orderkey,
        o_custkey,
        o_orderdate,
        o_totalprice
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS

),

joined_data AS (

    SELECT
        o.o_orderdate,
        l.l_partkey,
        l.l_suppkey,
        SUM(l.l_extendedprice) AS revenue
    FROM large_lineitems l
    JOIN large_orders o
      ON l.l_orderkey = o.o_orderkey
    GROUP BY
        o.o_orderdate,
        l.l_partkey,
        l.l_suppkey

)

SELECT *
FROM joined_data
-- Another low-selectivity predicate
WHERE o_orderdate >= DATE '1995-01-01';
