-- ============================================================
-- 01_create_tables.sql
-- Run this FIRST, in Superset SQL Lab, against the "regtech" database
-- ============================================================

CREATE TABLE xbrl_submissions (
  submission_id      VARCHAR(20) PRIMARY KEY,
  entity_id          VARCHAR(15) NOT NULL,
  entity_name        VARCHAR(100) NOT NULL,
  entity_type        VARCHAR(30),   -- 'Bank', 'NBFC', 'Insurance', 'MFI'
  reporting_period   DATE NOT NULL,
  submission_date    TIMESTAMP NOT NULL,
  taxonomy_version   VARCHAR(10),   -- e.g. 'IRIS-4.2', 'IRIS-3.9'
  filing_type        VARCHAR(20),   -- 'Annual', 'Quarterly', 'Monthly'
  regulator          VARCHAR(30),   -- 'RBI', 'SEBI', 'IRDAI', 'NHB'
  status             VARCHAR(20),   -- 'Accepted','Rejected','Under Review'
  total_assets       NUMERIC(18,2),
  net_profit         NUMERIC(18,2),
  capital_adequacy   NUMERIC(6,3),  -- CAR %
  npa_ratio          NUMERIC(6,3),  -- NPA %
  liquidity_ratio    NUMERIC(6,3),
  region             VARCHAR(30),   -- 'North', 'South', 'East', 'West'
  state              VARCHAR(30),
  validation_errors  INTEGER DEFAULT 0,
  resubmission_count INTEGER DEFAULT 0
);

CREATE TABLE non_xbrl_returns (
  return_id          VARCHAR(20) PRIMARY KEY,
  entity_id          VARCHAR(15) NOT NULL,
  entity_name        VARCHAR(100) NOT NULL,
  return_type        VARCHAR(40),   -- 'ALM','DCCO','SLR','CRR','FRL','CSR','FLR'
  submission_format  VARCHAR(20),   -- 'Excel','PDF','CSV','Manual'
  due_date           DATE NOT NULL,
  actual_submission  DATE,
  days_delayed       INTEGER GENERATED ALWAYS AS
    (CASE WHEN actual_submission IS NOT NULL
          THEN actual_submission - due_date ELSE NULL END) STORED,
  regulator          VARCHAR(30),
  compliance_status  VARCHAR(20),   -- 'On Time','Delayed','Pending','Missed'
  penalty_amount     NUMERIC(14,2) DEFAULT 0,
  region             VARCHAR(30),
  state              VARCHAR(30),
  reviewer_id        VARCHAR(15),
  remarks            TEXT
);
