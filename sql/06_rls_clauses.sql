-- ============================================================
-- Row Level Security clauses (Security > Row Level Security in Superset)
-- ============================================================

-- ------------------------------------------------------------
-- RLS Rule 1 — Regulator Scoping
-- Filter Type : Regular
-- Table       : xbrl_submissions
-- Role        : RegTech_Analyst
-- Group Key   : regulator
-- ------------------------------------------------------------
-- Dynamic, attribute-driven clause (preferred — supports multiple
-- analysts each scoped to their own regulator without separate rules):
regulator IN (
  SELECT value FROM user_attribute WHERE
  user_id = (SELECT id FROM ab_user WHERE username = '{{ current_username() }}')
  AND key = 'regulator_scope'
)

-- Static fallback (single-tenant demo environment):
-- regulator = 'RBI'


-- ------------------------------------------------------------
-- RLS Rule 2 — Regional Scoping
-- Filter Type : Regular
-- Table       : non_xbrl_returns
-- Role        : RegTech_Analyst
-- Group Key   : region
-- ------------------------------------------------------------
-- URL-parameter driven clause (lets one shared analyst role be scoped
-- per-session via a signed dashboard link, e.g. ?region=South):
region = '{{ url_param('region') }}'

-- Static fallback if URL params aren't wired up for this environment:
-- region IN ('South', 'West')


-- ------------------------------------------------------------
-- RLS Rule 3 — Status Restriction for Public Role
-- Filter Type : Regular
-- Table       : xbrl_submissions
-- Role        : Public_Viewer
-- Group Key   : status
-- ------------------------------------------------------------
status = 'Accepted'

-- ============================================================
-- Extending Rule 1 to a true multi-tenant dynamic clause
-- ============================================================

-- The current implementation is designed to resolve a single attribute value for each user.
-- To support users who are responsible for multiple regulators—such as cross-regulator reviewers—the regulator_scope attribute can be stored as multiple records (or as a multi-valued attribute).
-- Since the existing IN subquery already returns a set of values, it can naturally handle multiple regulators without requiring any changes to the clause itself.

-- For more advanced scenarios, such as hierarchical access where a user should be able to view data for their assigned region as well as all subordinate regions, the attribute lookup can be extended through a join with a region_hierarchy mapping table. The hierarchy would still be driven by the current user's identity, ensuring that the subquery remains deterministic and can be consistently applied by Superset across all generated chart queries.

