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
-- The current clause resolves a SINGLE attribute value per user. To
-- support analysts who legitimately oversee more than one regulator
-- (e.g. a cross-regulator reviewer), model regulator_scope as a
-- comma-delimited or multi-row user_attribute and keep the IN (...)
-- subquery as-is — it already returns a set, not a scalar, so multiple
-- rows under the same key naturally extend to multiple regulators with
-- no clause change. For org-hierarchy-aware scoping (e.g. "see your
-- region AND every region under it"), replace the flat user_attribute
-- lookup with a join against a small region_hierarchy mapping table,
-- keyed by the same current_username() lookup, so the WHERE clause
-- still resolves to a single deterministic subquery Superset can inject
-- into every generated chart query.
