
WITH non_xbrl_latest AS (
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
    x.entity_id,
    x.entity_name,
    x.entity_type,
    x.regulator,
    x.region,
    x.state,
    x.capital_adequacy,
    x.npa_ratio,
    x.status  AS xbrl_filing_status,
    x.validation_errors,
    x.resubmission_count,
--  Non-XBRL table (clearly aliased to avoid collisionFrom with XBRL status)
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
        WHEN x.npa_ratio > 6 OR nl.compliance_status = 'Missed' THEN 'High'
        WHEN x.npa_ratio > 3 OR nl.compliance_status = 'Delayed' THEN 'Medium'
        WHEN x.npa_ratio <= 3 AND nl.compliance_status = 'On Time' THEN 'Low'
        ELSE 'Medium'
    END AS risk_category

FROM xbrl_submissions x
LEFT JOIN non_xbrl_latest   nl ON nl.entity_id = x.entity_id AND nl.rn = 1
LEFT JOIN non_xbrl_summary  ns ON ns.entity_id = x.entity_id;

-- ============================================================
-- JOIN strategy justification
-- ============================================================
-- -**Join Logic Explanation**

-- The two datasets are linked using **`entity_id`**, as it is the only common business identifier between them. The columns `submission_id` and `return_id` are dataset-specific surrogate keys and therefore cannot be used for joining.
-- A **LEFT JOIN** is performed from **`xbrl_submissions`** to the non-XBRL dataset because the analysis is centered on XBRL submissions. Every regulated entity is expected to submit XBRL returns, but not every entity will have a corresponding non-XBRL return within the same reporting period. This can happen for reasons such as newly registered entities or non-XBRL returns not yet being due. Using an **INNER JOIN** would exclude these valid XBRL submissions, resulting in inaccurate submission counts and incomplete regulatory coverage. A **RIGHT JOIN** would instead make non-XBRL returns the primary dataset, which does not match the intended reporting focus.
-- To avoid duplicate records, the non-XBRL data is first aggregated so that there is only one record per `entity_id`. Without this step, entities with multiple historical non-XBRL returns would create multiple matches for a single XBRL submission, causing inflated counts and incorrect dashboard metrics.
-- By pre-aggregating the non-XBRL data and then applying a **LEFT JOIN**, the final dataset maintains the correct level of detail: **one row for each XBRL submission**, with non-XBRL information included whenever it is available.

