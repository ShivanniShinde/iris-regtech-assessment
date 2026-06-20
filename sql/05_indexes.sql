-- ============================================================
-- 6A. Query Profiling — representative dashboard query
-- ============================================================
-- This mirrors a real "Submissions by Regulator & Quarter" style
-- chart: date filter + 2 GROUP BY dims + 3 aggregates + 1 computed column.

EXPLAIN ANALYZE
SELECT
    regulator,
    entity_type,
    COUNT(*)                                                            AS total_submissions,
    AVG(capital_adequacy)                                               AS avg_capital_adequacy,
    SUM(total_assets)                                                   AS total_assets_sum,
    ROUND(
        100.0 * SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
    , 2)                                                                 AS rejection_rate_pct
FROM xbrl_submissions
WHERE reporting_period BETWEEN '2023-01-01' AND '2024-12-31'
GROUP BY regulator, entity_type
ORDER BY rejection_rate_pct DESC;

-- ============================================================
-- BEFORE optimisation — expected plan shape (PostgreSQL)
-- ============================================================
-- Sort  (cost=... rows=...)
--   ->  HashAggregate  (cost=... rows=...)
--         Group Key: regulator, entity_type
--         ->  Seq Scan on xbrl_submissions
--               Filter: (reporting_period >= '2023-01-01' AND reporting_period <= '2024-12-31')
--               Rows Removed by Filter: <large number>
--
-- Named bottleneck: Sequential Scan on xbrl_submissions.
-- At 1,000,000+ rows, Postgres must read every row and evaluate the
-- date filter row-by-row before it can even begin grouping, because
-- there is no index to jump straight to the qualifying date range.
-- This scales linearly with table size — the exact failure mode that
-- shows up as "the dashboard chart is slow" once real data volumes
-- are loaded, even though the seed data (25 rows) hides the problem
-- completely.

-- ============================================================
-- Index design
-- ============================================================
-- Composite index leads with the filter column (reporting_period,
-- highest selectivity / used in a range predicate) followed by the
-- two GROUP BY columns, so the planner can satisfy the WHERE filter
-- via an Index Scan/Bitmap Index Scan AND feed already-partially-
-- sorted, narrowed data into the aggregate — avoiding a full table
-- scan. INCLUDE adds the aggregated columns as non-key payload so
-- Postgres can answer the query straight from the index (index-only
-- scan) without touching the heap.

CREATE INDEX idx_xbrl_period_regulator_type
    ON xbrl_submissions (reporting_period, regulator, entity_type)
    INCLUDE (status, capital_adequacy, total_assets);

-- MySQL 8.0+ equivalent (no INCLUDE clause — add covering columns
-- directly into the composite key, accepting the wider index):
-- CREATE INDEX idx_xbrl_period_regulator_type
--     ON xbrl_submissions (reporting_period, regulator, entity_type, status, capital_adequacy, total_assets);

-- Informix equivalent:
-- CREATE INDEX idx_xbrl_period_regulator_type
--     ON xbrl_submissions (reporting_period, regulator, entity_type);

-- ============================================================
-- AFTER optimisation — expected plan shape (PostgreSQL)
-- ============================================================
-- Sort  (cost=... rows=...)
--   ->  HashAggregate  (cost=... rows=...)
--         ->  Index Only Scan using idx_xbrl_period_regulator_type on xbrl_submissions
--               Index Cond: (reporting_period >= '2023-01-01' AND reporting_period <= '2024-12-31')
--
-- Expected improvement: the Seq Scan (O(n) over the full table, ~1M
-- row visits) is replaced by an Index (Only) Scan that visits roughly
-- the number of rows actually inside the 2-year date window — typically
-- a small fraction of the table. Run ANALYZE xbrl_submissions; after
-- index creation so the planner's row-count estimates reflect the new
-- index. Expect execution time to drop from several hundred
-- milliseconds–low seconds (depending on hardware) down to tens of
-- milliseconds, and "Rows Removed by Filter" to disappear entirely
-- because the filter is now satisfied by the index condition rather
-- than a post-scan row-by-row check.
