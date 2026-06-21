
INSERT INTO xbrl_submissions (
  submission_id, entity_id, entity_name, entity_type,
  reporting_period, submission_date, taxonomy_version,
  filing_type, regulator, status, total_assets, net_profit,
  capital_adequacy, npa_ratio, liquidity_ratio,
  region, state, validation_errors, resubmission_count
)
SELECT
  'XB-GEN-' || LPAD(gs::TEXT, 7, '0'),
  ent.eid,
  ent.ename,
  ent.etype,
  (DATE '2019-01-01' + (floor(random() * 72) || ' months')::INTERVAL)::DATE,
  (DATE '2019-01-01' + (floor(random() * 72) || ' months')::INTERVAL
    + (floor(random() * 50 + 1) || ' days')::INTERVAL),
  (ARRAY['IRIS-3.8','IRIS-3.9','IRIS-4.0','IRIS-4.1','IRIS-4.2'])
    [1 + floor(random()*5)::INT],
  (ARRAY['Annual','Quarterly','Monthly'])[1 + floor(random()*3)::INT],
  CASE ent.etype
    WHEN 'Insurance' THEN 'IRDAI'
    WHEN 'Bank'      THEN (ARRAY['RBI','RBI','RBI','SEBI'])[1 + floor(random()*4)::INT]
    ELSE 'RBI'
  END,
  CASE
    WHEN random() < 0.68 THEN 'Accepted'
    WHEN random() < 0.85 THEN 'Under Review'
    WHEN random() < 0.95 THEN 'Rejected'
    ELSE 'Pending'
  END,
  ROUND((
    CASE ent.etype
      WHEN 'Bank'      THEN random() * 200000000000 + 5000000000
      WHEN 'NBFC'      THEN random() * 20000000000  + 500000000
      WHEN 'Insurance' THEN random() * 500000000000 + 10000000000
      WHEN 'MFI'       THEN random() * 2000000000   + 100000000
    END
  )::NUMERIC, 2),
  CASE WHEN random() > 0.12 THEN ROUND((random()*5000000000+10000000)::NUMERIC,2)
       ELSE NULL END,
  CASE WHEN ent.etype <> 'Insurance' AND random() > 0.08
       THEN ROUND((random()*15+9)::NUMERIC, 3) ELSE NULL END,
  CASE WHEN ent.etype <> 'Insurance' AND random() > 0.08
       THEN ROUND((random()*12)::NUMERIC, 3) ELSE NULL END,
  ROUND((random()*30+10)::NUMERIC, 3),
  ent.eregion,
  ent.estate,
  floor(random()*15)::INT,
  floor(random()*5)::INT
FROM generate_series(1, 1000000) gs
CROSS JOIN LATERAL (
  SELECT * FROM (
    VALUES
      ('ENT001','Axis Cooperative Bank',     'Bank',      'West',    'Maharashtra'),
      ('ENT002','Sunrise NBFC Ltd',          'NBFC',      'South',   'Tamil Nadu'),
      ('ENT003','Bharat Life Insurance',     'Insurance', 'North',   'Delhi'),
      ('ENT004','Green Horizon MFI',         'MFI',       'East',    'West Bengal'),
      ('ENT005','National Urban Bank',       'Bank',      'North',   'Uttar Pradesh'),
      ('ENT006','Deccan Finance Corp',       'NBFC',      'South',   'Karnataka'),
      ('ENT007','Eastern Gramin Bank',       'Bank',      'East',    'Odisha'),
      ('ENT008','Himalayan Micro Finance',   'MFI',       'North',   'Himachal Pradesh'),
      ('ENT009','Coastal General Insurance', 'Insurance', 'South',   'Kerala'),
      ('ENT010','Capital Edge NBFC',         'NBFC',      'West',    'Gujarat'),
      ('ENT011','Pioneer Rural Bank',        'Bank',      'Central', 'Madhya Pradesh'),
      ('ENT012','Indus Valley NBFC',         'NBFC',      'West',    'Rajasthan'),
      ('ENT013','Metro Life Assurance',      'Insurance', 'West',    'Maharashtra'),
      ('ENT014','Sunrise Gramin MFI',        'MFI',       'West',    'Maharashtra'),
      ('ENT015','Tamil Cooperative Bank',    'Bank',      'South',   'Tamil Nadu'),
      ('ENT016','North Star Finance',        'NBFC',      'North',   'Punjab'),
      ('ENT017','Ganga Valley Bank',         'Bank',      'North',   'Uttarakhand'),
      ('ENT018','South Bay Microfinance',    'MFI',       'South',   'Andhra Pradesh'),
      ('ENT019','West Coast Insurance',      'Insurance', 'West',    'Gujarat'),
      ('ENT020','Central India NBFC',        'NBFC',      'Central', 'Chhattisgarh'),
      ('ENT021','Kerala Gramin Bank',        'Bank',      'South',   'Kerala'),
      ('ENT022','NE Finance Ltd',            'NBFC',      'East',    'Assam'),
      ('ENT023','Bharat Health Insurance',   'Insurance', 'North',   'Delhi'),
      ('ENT024','Sundarbans MFI Trust',      'MFI',       'East',    'West Bengal'),
      ('ENT025','Plateau Urban Bank',        'Bank',      'Central', 'Jharkhand')
  ) AS e(eid, ename, etype, eregion, estate)
  ORDER BY random() LIMIT 1
) AS ent;

INSERT INTO non_xbrl_returns (
  return_id, entity_id, entity_name, return_type,
  submission_format, due_date, actual_submission,
  regulator, compliance_status, penalty_amount,
  region, state, reviewer_id, remarks
)
SELECT
  'NX-GEN-' || LPAD(gs::TEXT, 7, '0'),
  ent.eid,
  ent.ename,
  (ARRAY['ALM','DCCO','SLR','CRR','FRL','CSR','FLR'])[1 + floor(random()*7)::INT],
  (ARRAY['Excel','PDF','CSV','Manual'])[1 + floor(random()*4)::INT],
  (DATE '2019-01-31' + (floor(random() * 60) || ' months')::INTERVAL)::DATE,
  CASE
    WHEN random() < 0.62 THEN
      (DATE '2019-01-31' + (floor(random()*60) || ' months')::INTERVAL
        - (floor(random()*3) || ' days')::INTERVAL)::DATE
    WHEN random() < 0.80 THEN
      (DATE '2019-01-31' + (floor(random()*60) || ' months')::INTERVAL
        + (floor(random()*30+1) || ' days')::INTERVAL)::DATE
    ELSE NULL
  END,
  CASE ent.etype
    WHEN 'Insurance' THEN 'IRDAI' ELSE 'RBI'
  END,
  CASE
    WHEN random() < 0.60 THEN 'On Time'
    WHEN random() < 0.80 THEN 'Delayed'
    WHEN random() < 0.92 THEN 'Pending'
    ELSE 'Missed'
  END,
  CASE
    WHEN random() < 0.60 THEN 0
    WHEN random() < 0.80 THEN ROUND((random()*50000+1000)::NUMERIC, 2)
    ELSE ROUND((random()*500000+50000)::NUMERIC, 2)
  END,
  ent.eregion,
  ent.estate,
  'REV0' || (1 + floor(random()*4)::INT)::TEXT,
  (ARRAY[
    'Clean submission','Minor delay noted','Penalty applied',
    'Repeat defaulter','Under review','Escalated to regulator',
    'Accepted with remarks','On schedule','Early submission'
  ])[1 + floor(random()*9)::INT]
FROM generate_series(1, 500000) gs
CROSS JOIN LATERAL (
  SELECT * FROM (
    VALUES
      ('ENT001','Axis Cooperative Bank',     'Bank',      'West',    'Maharashtra'),
      ('ENT002','Sunrise NBFC Ltd',          'NBFC',      'South',   'Tamil Nadu'),
      ('ENT003','Bharat Life Insurance',     'Insurance', 'North',   'Delhi'),
      ('ENT004','Green Horizon MFI',         'MFI',       'East',    'West Bengal'),
      ('ENT005','National Urban Bank',       'Bank',      'North',   'Uttar Pradesh'),
      ('ENT006','Deccan Finance Corp',       'NBFC',      'South',   'Karnataka'),
      ('ENT007','Eastern Gramin Bank',       'Bank',      'East',    'Odisha'),
      ('ENT008','Himalayan Micro Finance',   'MFI',       'North',   'Himachal Pradesh'),
      ('ENT009','Coastal General Insurance', 'Insurance', 'South',   'Kerala'),
      ('ENT010','Capital Edge NBFC',         'NBFC',      'West',    'Gujarat'),
      ('ENT011','Pioneer Rural Bank',        'Bank',      'Central', 'Madhya Pradesh'),
      ('ENT012','Indus Valley NBFC',         'NBFC',      'West',    'Rajasthan'),
      ('ENT013','Metro Life Assurance',      'Insurance', 'West',    'Maharashtra'),
      ('ENT014','Sunrise Gramin MFI',        'MFI',       'West',    'Maharashtra'),
      ('ENT015','Tamil Cooperative Bank',    'Bank',      'South',   'Tamil Nadu'),
      ('ENT016','North Star Finance',        'NBFC',      'North',   'Punjab'),
      ('ENT017','Ganga Valley Bank',         'Bank',      'North',   'Uttarakhand'),
      ('ENT018','South Bay Microfinance',    'MFI',       'South',   'Andhra Pradesh'),
      ('ENT019','West Coast Insurance',      'Insurance', 'West',    'Gujarat'),
      ('ENT020','Central India NBFC',        'NBFC',      'Central', 'Chhattisgarh')
  ) AS e(eid, ename, etype, eregion, estate)
  ORDER BY random() LIMIT 1
) AS ent;


SELECT 'xbrl_submissions' AS tbl, COUNT(*) FROM xbrl_submissions
UNION ALL
SELECT 'non_xbrl_returns', COUNT(*) FROM non_xbrl_returns;
