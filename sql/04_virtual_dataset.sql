-- ============================================================
-- Virtual Dataset: compliance_risk_score
-- Target DB: PostgreSQL 14+ (also valid on MySQL 8.0+ — ROW_NUMBER()
-- and CTEs are supported on both; see compatibility notes at bottom)
-- ============================================================

WITH non_xbrl_latest AS (
    -- One row per entity: their MOST RECENT non-XBRL return,
    -- determined by due_date. This avoids row duplication when an
    -- entity has many historical returns.
    SELECT
        entity_id,
        compliance_status,
        days_delayed,
        penalty_amount,
        ROW_NUMBER() OVER (
            PARTITION BY entity_id
            ORDER BY due_date DESC
        ) AS rn
    FROM non_xbrl_returns
),

non_xbrl_summary AS (
    -- Aggregated compliance history per entity, used to make the
    -- risk_category logic robust rather than dependent on a single
    -- snapshot record.
    SELECT
        entity_id,
        SUM(COALESCE(penalty_amount, 0))                              AS total_penalty_amount,
        MAX(days_delayed)                                             AS max_days_delayed,
        SUM(CASE WHEN compliance_status = 'Missed'  THEN 1 ELSE 0 END) AS missed_return_count,
        SUM(CASE WHEN compliance_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_return_count,
        COUNT(*)                                                      AS total_returns_filed
    FROM non_xbrl_returns
    GROUP BY entity_id
)

SELECT
    -- Entity identifiers
    x.entity_id,
    x.entity_name,
    x.entity_type,
    x.regulator,
    x.region,
    x.state,

    -- From XBRL table
    x.capital_adequacy,
    x.npa_ratio,
    x.status                         AS xbrl_filing_status,
    x.validation_errors,
    x.resubmission_count,

    -- From Non-XBRL table (clearly aliased to avoid collision with XBRL status)
    nl.compliance_status             AS non_xbrl_compliance_status,
    nl.days_delayed,
    nl.penalty_amount,

    -- Supplementary aggregates (useful for charts/metrics, not strictly
    -- required but cheap to expose since the CTE already computes them)
    ns.total_penalty_amount,
    ns.max_days_delayed,
    ns.missed_return_count,
    ns.delayed_return_count,
    ns.total_returns_filed,

    -- ============================================================
    -- risk_category: robust CASE logic
    --
    -- Design intent:
    --  1. NPA ratio is the primary prudential signal (capital quality).
    --  2. Non-XBRL compliance behaviour (timeliness/penalties) is the
    --     secondary signal (operational/regulatory discipline).
    --  3. Either signal independently breaching a threshold is enough
    --     to escalate risk — risk should never be "averaged down".
    --  4. NULLs are handled explicitly at every branch — an entity
    --     with no NPA data (e.g. Insurance, where npa_ratio is
    --     structurally NULL) must not silently fall through to a
    --     false "Low" rating, and an entity with no non-XBRL filing
    --     history yet is "Unrated", not "Low".
    -- ============================================================
    CASE
        -- Both signals missing entirely: nothing to score on
        WHEN x.npa_ratio IS NULL AND nl.compliance_status IS NULL THEN 'Unrated'

        -- NPA missing (e.g. Insurance entities) — fall back to
        -- compliance behaviour only
        WHEN x.npa_ratio IS NULL THEN
            CASE
                WHEN nl.compliance_status = 'Missed'  THEN 'High'
                WHEN nl.compliance_status = 'Delayed' THEN 'Medium'
                WHEN nl.compliance_status = 'On Time' THEN 'Low'
                ELSE 'Unrated'
            END

        -- Compliance status missing — fall back to NPA only
        WHEN nl.compliance_status IS NULL THEN
            CASE
                WHEN x.npa_ratio > 6 THEN 'High'
                WHEN x.npa_ratio > 3 THEN 'Medium'
                ELSE 'Low'
            END

        -- Both signals present: either one breaching High overrides everything
        WHEN x.npa_ratio > 6 OR nl.compliance_status = 'Missed' THEN 'High'

        -- Either one breaching Medium
        WHEN x.npa_ratio > 3 OR nl.compliance_status = 'Delayed' THEN 'Medium'

        -- Both clean
        WHEN x.npa_ratio <= 3 AND nl.compliance_status = 'On Time' THEN 'Low'

        -- Defensive catch-all (e.g. unexpected compliance_status values)
        ELSE 'Medium'
    END AS risk_category

FROM xbrl_submissions x
LEFT JOIN non_xbrl_latest   nl ON nl.entity_id = x.entity_id AND nl.rn = 1
LEFT JOIN non_xbrl_summary  ns ON ns.entity_id = x.entity_id;

-- ============================================================
-- JOIN strategy justification
-- ============================================================
-- Join key: entity_id (the only natural key shared by both tables;
-- submission_id/return_id are independent surrogate keys per dataset).
--
-- Join type: LEFT JOIN from xbrl_submissions -> non_xbrl_*.
--   xbrl_submissions is treated as the "driving"/fact table because
--   every regulated entity files XBRL returns, but not every entity
--   necessarily has a matching non-XBRL return in a given window
--   (e.g. newly onboarded entities, or entities whose non-XBRL
--   return isn't due yet). An INNER JOIN would silently drop those
--   XBRL submissions, understating regulatory coverage and corrupting
--   any "Total Submissions" KPI that should reflect ALL XBRL filings.
--   A RIGHT JOIN would invert the grain to non-XBRL returns, which
--   is wrong because the dashboards are XBRL-submission-centric.
--   LEFT JOIN guarantees one row per xbrl_submissions row (the
--   required grain) while still attaching compliance context where
--   it exists.
--
-- Fan-out prevention: non_xbrl_returns has a one-to-many relationship
-- with entity_id (many returns per entity over time). Joining directly
-- on entity_id without pre-aggregation would multiply each XBRL row by
-- however many non-XBRL returns that entity has, inflating COUNT(*)-based
-- metrics. The non_xbrl_latest and non_xbrl_summary CTEs collapse the
-- non-XBRL side to exactly one row per entity_id BEFORE the join, which
-- keeps the final grain correct: one row per xbrl_submissions record.
--
-- ============================================================
-- Compatibility notes
-- ============================================================
-- PostgreSQL: works as-is.
-- MySQL 8.0+: works as-is (CTEs and ROW_NUMBER() are supported from 8.0).
-- Informix: does not support WITH ... AS CTEs in the same dialect used here
--   in all versions; rewrite the two CTEs as derived tables in FROM/JOIN
--   subqueries, and replace ROW_NUMBER() with a correlated subquery using
--   FIRST 1 ... ORDER BY due_date DESC if running on an older Informix release.
