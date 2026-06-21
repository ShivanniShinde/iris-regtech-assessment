
CREATE TABLE xbrl_submissions (
  submission_id      VARCHAR(20) PRIMARY KEY,
  entity_id          VARCHAR(15) NOT NULL,
  entity_name        VARCHAR(100) NOT NULL,
  entity_type        VARCHAR(30),   
  reporting_period   DATE NOT NULL,
  submission_date    TIMESTAMP NOT NULL,
  taxonomy_version   VARCHAR(10),   
  filing_type        VARCHAR(20),   
  regulator          VARCHAR(30),
  status             VARCHAR(20),
  total_assets       NUMERIC(18,2),
  net_profit         NUMERIC(18,2),
  capital_adequacy   NUMERIC(6,3),
  npa_ratio          NUMERIC(6,3),
  liquidity_ratio    NUMERIC(6,3),
  region             VARCHAR(30),
  state              VARCHAR(30),
  validation_errors  INTEGER DEFAULT 0,
  resubmission_count INTEGER DEFAULT 0
);

CREATE TABLE non_xbrl_returns (
  return_id          VARCHAR(20) PRIMARY KEY,
  entity_id          VARCHAR(15) NOT NULL,
  entity_name        VARCHAR(100) NOT NULL,
  return_type        VARCHAR(40),
  submission_format  VARCHAR(20),
  due_date           DATE NOT NULL,
  actual_submission  DATE,
  days_delayed       INTEGER GENERATED ALWAYS AS
    (CASE WHEN actual_submission IS NOT NULL
          THEN actual_submission - due_date ELSE NULL END) STORED,
  regulator          VARCHAR(30),
  compliance_status  VARCHAR(20),
  penalty_amount     NUMERIC(14,2) DEFAULT 0,
  region             VARCHAR(30),
  state              VARCHAR(30),
  reviewer_id        VARCHAR(15),
  remarks            TEXT
);
