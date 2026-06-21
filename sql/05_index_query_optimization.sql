-- ============================================================
-- TASK 5 — Query Profiling & Index Optimisation
-- Table: xbrl_submissions (~1,000,025 rows)
-- ============================================================


-- ============================================================
-- STEP 1 — THE QUERY (run in SQL Lab)
-- Regulatory rejection rate analysis grouped by regulator
-- and entity type, filtered to a 2-year reporting window.
-- This mirrors a real dashboard chart requirement.
-- ============================================================

EXPLAIN ANALYZE
SELECT
    regulator,
    entity_type,
    COUNT(*)                                                             AS total_submissions,
    AVG(capital_adequacy)                                                AS avg_capital_adequacy,
    SUM(total_assets)                                                    AS total_assets_sum,
    ROUND(
        100.0 * SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
    , 2)                                                                 AS rejection_rate_pct
FROM xbrl_submissions
WHERE reporting_period BETWEEN '2023-01-01' AND '2024-12-31'
GROUP BY regulator, entity_type
ORDER BY rejection_rate_pct DESC;


-- ============================================================
-- STEP 2 — BEFORE OPTIMISATION: ACTUAL EXPLAIN ANALYZE OUTPUT
-- (captured from SQL Lab before any index was created)
-- ============================================================

-- Sort  (cost=34078.47..34078.49 rows=9 width=113)
--       (actual time=1611.253..1615.651 rows=5 loops=1)
--   Sort Key: (round(((100.0 * (sum(CASE WHEN ((status)::text = 'Rejected'::text)
--              THEN 1 ELSE 0 END))::numeric) / (NULLIF(count(*), 0))::numeric), 2)) DESC
--   Sort Method: quicksort  Memory: 25kB
--   ->  Finalize GroupAggregate
--         (cost=34075.59..34078.32 rows=9 width=113)
--         (actual time=1610.809..1615.271 rows=5 loops=1)
--         Group Key: regulator, entity_type
--         ->  Gather Merge
--               (cost=34075.59..34077.69 rows=18 width=89)
--               (actual time=1610.157..1614.561 rows=9 loops=1)
--               Workers Planned: 2
--               Workers Launched: 2
--               ->  Sort  (cost=33075.57..33075.59 rows=9 width=89)
--                         (actual time=1590.910..1590.912 rows=3 loops=3)
--                     Sort Key: regulator, entity_type
--                     Sort Method: quicksort  Memory: 26kB
--                     Worker 0:  Sort Method: quicksort  Memory: 25kB
--                     Worker 1:  Sort Method: quicksort  Memory: 25kB
--                     ->  Partial HashAggregate
--                           (cost=33075.29..33075.43 rows=9 width=89)
--                           (actual time=1590.332..1590.338 rows=3 loops=3)
--                           Group Key: regulator, entity_type
--                           Batches: 1  Memory Usage: 24kB
--                           Worker 0:  Batches: 1  Memory Usage: 24kB
--                           Worker 1:  Batches: 1  Memory Usage: 24kB
--                           ->  Parallel Seq Scan on xbrl_submissions
--                                 (cost=0.00..30637.16 rows=139322 width=35)
--                                 (actual time=8.759..1515.792 rows=111082 loops=3)
--                                 Filter: ((reporting_period >= '2023-01-01'::date)
--                                      AND (reporting_period <= '2024-12-31'::date))
--                                 Rows Removed by Filter: 222259
-- Planning Time:  13.467 ms
-- Execution Time: 1618.561 ms


-- ============================================================
-- BOTTLENECK IDENTIFIED: Parallel Sequential Scan
--
-- PostgreSQL performed a full table scan across all ~1,000,025
-- rows in xbrl_submissions. Even with 2 parallel workers, the
-- engine had to read every single row and evaluate the date
-- filter individually (row-by-row) before it could begin
-- grouping. This is confirmed by:
--
--   "Rows Removed by Filter: 222259"
--
-- This means 222,259 rows were read and then discarded because
-- they fell outside the date range. At 1M+ rows, a Seq Scan
-- scales linearly O(n) with table size — every dashboard
-- refresh forces a full table read. This is the exact failure
-- mode that makes dashboards slow under real data volumes.
-- The total execution time of 1618 ms is unacceptable for an
-- interactive dashboard chart that analysts expect instantly.
-- ============================================================


-- ============================================================
-- STEP 3 — INDEX DESIGN & CREATION
--
-- Strategy:
--   1. Lead with reporting_period — it is the WHERE filter
--      column with the highest selectivity on a range
--      predicate. Placing it first lets PostgreSQL jump
--      directly to qualifying rows instead of scanning all.
--
--   2. Include regulator and entity_type as index key columns
--      — these are the GROUP BY columns. Having them in the
--      index means the planner can feed pre-sorted, already-
--      filtered data into the aggregation step.
--
--   3. INCLUDE the remaining aggregated columns (status,
--      capital_adequacy, total_assets) as non-key payload.
--      This enables an Index-Only Scan: PostgreSQL can answer
--      the entire query from the index without ever touching
--      the heap (the table's physical pages).
--
--   Index type: default B-tree — optimal for range predicates
--   (BETWEEN / >= / <=) and equality GROUP BY lookups.
-- ============================================================

CREATE INDEX idx_xbrl_period_regulator_type
    ON xbrl_submissions (reporting_period, regulator, entity_type)
    INCLUDE (status, capital_adequacy, total_assets);

-- Refresh planner statistics so the new index is used:
ANALYZE xbrl_submissions;


-- ============================================================
-- STEP 4 — AFTER OPTIMISATION: ACTUAL EXPLAIN ANALYZE OUTPUT
-- (captured from SQL Lab after index creation + ANALYZE)
-- ============================================================

-- Sort  (cost=18498.23..18498.25 rows=9 width=113)
--       (actual time=52.245..56.338 rows=5 loops=1)
--   Sort Key: (round(((100.0 * (sum(CASE WHEN ((status)::text = 'Rejected'::text)
--              THEN 1 ELSE 0 END))::numeric) / (NULLIF(count(*), 0))::numeric), 2)) DESC
--   Sort Method: quicksort  Memory: 25kB
--   ->  Finalize GroupAggregate
--         (cost=18495.36..18498.09 rows=9 width=113)
--         (actual time=52.198..56.315 rows=5 loops=1)
--         Group Key: regulator, entity_type
--         ->  Gather Merge
--               (cost=18495.36..18497.46 rows=18 width=89)
--               (actual time=52.183..56.277 rows=13 loops=1)
--               Workers Planned: 2
--               Workers Launched: 2
--               ->  Sort  (cost=17495.33..17495.36 rows=9 width=89)
--                         (actual time=48.182..48.183 rows=4 loops=3)
--                     Sort Key: regulator, entity_type
--                     Sort Method: quicksort  Memory: 25kB
--                     Worker 0:  Sort Method: quicksort  Memory: 26kB
--                     Worker 1:  Sort Method: quicksort  Memory: 26kB
--                     ->  Partial HashAggregate
--                           (cost=17495.06..17495.19 rows=9 width=89)
--                           (actual time=48.152..48.155 rows=4 loops=3)
--                           Group Key: regulator, entity_type
--                           Batches: 1  Memory Usage: 24kB
--                           Worker 0:  Batches: 1  Memory Usage: 24kB
--                           Worker 1:  Batches: 1  Memory Usage: 24kB
--                           ->  Parallel Index Only Scan using
--                                 idx_xbrl_period_regulator_type
--                                 on xbrl_submissions
--                                 (cost=0.42..15057.08 rows=139313 width=35)
--                                 (actual time=0.026..17.533 rows=111082 loops=3)
--                                 Index Cond: ((reporting_period >= '2023-01-01'::date)
--                                          AND (reporting_period <= '2024-12-31'::date))
--                                 Heap Fetches: 0
-- Planning Time:  0.552 ms
-- Execution Time: 56.435 ms


-- ============================================================
-- STEP 5 — WRITTEN ANALYSIS (>150 words)
--
-- BEFORE optimisation the query took 1618.561 ms to execute.
-- PostgreSQL chose a Parallel Sequential Scan on
-- xbrl_submissions, enlisting 2 workers to read all ~1,000,025
-- rows in parallel. Despite parallelism, 222,259 rows were
-- read and discarded after the date filter was applied — every
-- row in the table was touched before a single grouped result
-- could be produced. At this scale, a Seq Scan is O(n): as
-- the table grows, execution time grows proportionally.
-- Dashboard users would experience increasing load times with
-- every new period of regulatory data ingested.
--
-- The bottleneck was the absence of an index on
-- reporting_period. Without it, the query planner had no
-- efficient access path to the qualifying date range, so it
-- defaulted to reading the entire table.
--
-- The composite index idx_xbrl_period_regulator_type resolves
-- this in three ways. First, leading with reporting_period
-- gives the planner a B-tree range access path: it seeks
-- directly to '2023-01-01' and stops at '2024-12-31', visiting
-- only the rows that actually qualify. Second, adding regulator
-- and entity_type as key columns means the index already
-- groups the data in the order needed for the GROUP BY,
-- reducing aggregation cost. Third, the INCLUDE clause covers
-- status, capital_adequacy, and total_assets as non-key
-- payload, enabling an Index-Only Scan — PostgreSQL resolves
-- the entire SELECT list from the index pages alone, confirmed
-- by "Heap Fetches: 0" in the AFTER plan.
--
-- AFTER optimisation the query took just 56.435 ms — a
-- reduction of 1562 ms and a 96.5% improvement in execution
-- time. "Rows Removed by Filter: 222259" disappears entirely
-- because the index condition replaces the post-scan predicate:
-- the database no longer reads disqualifying rows at all. The
-- "Parallel Seq Scan" node is replaced by "Parallel Index Only
-- Scan", and planning time fell from 13.467 ms to 0.552 ms
-- because the planner immediately found a usable index path.
-- This improvement scales favourably: as the table grows to
-- 10M or 100M rows, the B-tree index seek still targets only
-- the qualifying date window, keeping dashboard response times
-- consistently fast for regulators and analysts.
--
-- Summary:
--   BEFORE  Execution Time : 1618.561 ms  (Parallel Seq Scan)
--   AFTER   Execution Time :   56.435 ms  (Parallel Index Only Scan)
--   Improvement            :  1562 ms faster  /  96.5% reduction
-- ============================================================
