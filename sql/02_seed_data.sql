-- 02_seed_data.sql
-- Run this in Superset SQL Lab AFTER 01_create_tables.sql

INSERT INTO xbrl_submissions VALUES
('XB-2024-001','ENT001','Axis Cooperative Bank','Bank','2024-03-31','2024-04-12 09:15:00','IRIS-4.2','Annual','RBI','Accepted',45200000000,1250000000,14.8,2.1,18.5,'West','Maharashtra',0,0),
('XB-2024-002','ENT002','Sunrise NBFC Ltd','NBFC','2024-03-31','2024-04-14 11:30:00','IRIS-4.2','Annual','RBI','Accepted',8700000000,320000000,16.2,4.5,22.1,'South','Tamil Nadu',2,1),
('XB-2024-003','ENT003','Bharat Life Insurance','Insurance','2024-03-31','2024-04-20 14:00:00','IRIS-3.9','Annual','IRDAI','Under Review',120000000000,5600000000,NULL,NULL,35.2,'North','Delhi',5,0),
('XB-2024-004','ENT004','Green Horizon MFI','MFI','2024-03-31','2024-04-10 08:45:00','IRIS-4.2','Annual','RBI','Accepted',950000000,42000000,18.5,3.2,25.0,'East','West Bengal',0,0),
('XB-2024-005','ENT005','National Urban Bank','Bank','2024-03-31','2024-04-30 16:20:00','IRIS-4.2','Annual','RBI','Rejected',89000000000,NULL,12.1,6.8,15.3,'North','Uttar Pradesh',12,3),
('XB-2024-006','ENT006','Deccan Finance Corp','NBFC','2023-12-31','2024-01-15 10:00:00','IRIS-4.1','Quarterly','RBI','Accepted',3200000000,98000000,15.7,5.1,19.8,'South','Karnataka',1,0),
('XB-2024-007','ENT007','Eastern Gramin Bank','Bank','2023-12-31','2024-01-18 09:30:00','IRIS-4.1','Quarterly','RBI','Accepted',12000000000,380000000,13.4,3.8,17.2,'East','Odisha',0,0),
('XB-2024-008','ENT008','Himalayan Micro Finance','MFI','2024-03-31','2024-04-09 07:50:00','IRIS-4.2','Annual','RBI','Accepted',650000000,28000000,19.2,2.9,27.5,'North','Himachal Pradesh',0,0),
('XB-2024-009','ENT009','Coastal General Insurance','Insurance','2024-03-31','2024-04-25 13:10:00','IRIS-4.2','Annual','IRDAI','Accepted',55000000000,2100000000,NULL,NULL,40.1,'South','Kerala',3,1),
('XB-2024-010','ENT010','Capital Edge NBFC','NBFC','2024-03-31','2024-05-02 15:30:00','IRIS-4.2','Annual','RBI','Rejected',5600000000,NULL,NULL,8.9,12.4,'West','Gujarat',18,4),
('XB-2024-011','ENT011','Pioneer Rural Bank','Bank','2023-09-30','2023-10-12 10:20:00','IRIS-4.0','Quarterly','RBI','Accepted',7800000000,210000000,14.2,4.2,16.8,'Central','Madhya Pradesh',0,0),
('XB-2024-012','ENT012','Indus Valley NBFC','NBFC','2023-09-30','2023-10-20 11:45:00','IRIS-4.0','Quarterly','RBI','Under Review',2100000000,65000000,17.1,5.8,20.3,'West','Rajasthan',7,0),
('XB-2024-013','ENT013','Metro Life Assurance','Insurance','2024-03-31','2024-04-15 09:00:00','IRIS-4.2','Annual','IRDAI','Accepted',88000000000,3800000000,NULL,NULL,38.6,'West','Maharashtra',1,0),
('XB-2024-014','ENT014','Sunrise Gramin MFI','MFI','2024-03-31','2024-04-11 08:00:00','IRIS-4.2','Annual','RBI','Accepted',430000000,18500000,20.1,2.5,29.3,'West','Maharashtra',0,0),
('XB-2024-015','ENT015','Tamil Cooperative Bank','Bank','2024-03-31','2024-04-13 10:15:00','IRIS-4.2','Annual','RBI','Accepted',22000000000,740000000,15.1,3.1,19.5,'South','Tamil Nadu',0,0),
('XB-2024-016','ENT016','North Star Finance','NBFC','2024-03-31','2024-04-16 14:30:00','IRIS-4.2','Annual','RBI','Accepted',4300000000,155000000,16.8,4.9,21.7,'North','Punjab',0,0),
('XB-2024-017','ENT017','Ganga Valley Bank','Bank','2023-12-31','2024-01-22 09:45:00','IRIS-4.1','Quarterly','RBI','Accepted',18500000000,620000000,13.9,3.5,18.0,'North','Uttarakhand',1,0),
('XB-2024-018','ENT018','South Bay Microfinance','MFI','2023-12-31','2024-01-10 07:30:00','IRIS-4.1','Quarterly','RBI','Rejected',280000000,NULL,16.5,7.2,14.8,'South','Andhra Pradesh',15,5),
('XB-2024-019','ENT019','West Coast Insurance','Insurance','2023-12-31','2024-01-28 12:00:00','IRIS-4.1','Quarterly','IRDAI','Accepted',34000000000,1400000000,NULL,NULL,36.9,'West','Gujarat',2,0),
('XB-2024-020','ENT020','Central India NBFC','NBFC','2024-03-31','2024-04-22 16:00:00','IRIS-4.2','Annual','RBI','Under Review',1850000000,NULL,15.3,6.1,18.9,'Central','Chhattisgarh',9,0),
('XB-2024-021','ENT021','Kerala Gramin Bank','Bank','2024-03-31','2024-04-11 09:00:00','IRIS-4.2','Annual','RBI','Accepted',9200000000,295000000,14.5,2.8,20.2,'South','Kerala',0,0),
('XB-2024-022','ENT022','NE Finance Ltd','NBFC','2024-03-31','2024-04-18 11:00:00','IRIS-4.2','Annual','RBI','Accepted',680000000,24000000,18.0,3.7,23.5,'East','Assam',1,0),
('XB-2024-023','ENT023','Bharat Health Insurance','Insurance','2024-03-31','2024-04-26 15:45:00','IRIS-4.2','Annual','IRDAI','Rejected',62000000000,NULL,NULL,NULL,28.1,'North','Delhi',22,6),
('XB-2024-024','ENT024','Sundarbans MFI Trust','MFI','2024-03-31','2024-04-09 08:10:00','IRIS-4.2','Annual','RBI','Accepted',340000000,15200000,21.3,2.2,31.0,'East','West Bengal',0,0),
('XB-2024-025','ENT025','Plateau Urban Bank','Bank','2024-03-31','2024-05-05 17:00:00','IRIS-4.2','Annual','RBI','Under Review',31000000000,NULL,11.8,5.5,14.1,'Central','Jharkhand',8,2);

INSERT INTO non_xbrl_returns
  (return_id,entity_id,entity_name,return_type,submission_format,due_date,actual_submission,regulator,compliance_status,penalty_amount,region,state,reviewer_id,remarks)
VALUES
('NX-2024-001','ENT001','Axis Cooperative Bank','ALM','Excel','2024-04-30','2024-04-28','RBI','On Time',0,'West','Maharashtra','REV01','Clean submission'),
('NX-2024-002','ENT002','Sunrise NBFC Ltd','SLR','Excel','2024-04-30','2024-05-07','RBI','Delayed',25000,'South','Tamil Nadu','REV02','Delayed by 7 days'),
('NX-2024-003','ENT003','Bharat Life Insurance','FRL','PDF','2024-04-30',NULL,'IRDAI','Pending',0,'North','Delhi','REV03','Awaiting upload'),
('NX-2024-004','ENT004','Green Horizon MFI','CSR','Excel','2024-04-30','2024-04-30','RBI','On Time',0,'East','West Bengal','REV01','Timely'),
('NX-2024-005','ENT005','National Urban Bank','CRR','Manual','2024-04-30','2024-05-20','RBI','Delayed',150000,'North','Uttar Pradesh','REV04','3 week delay'),
('NX-2024-006','ENT006','Deccan Finance Corp','ALM','Excel','2024-01-31','2024-01-31','RBI','On Time',0,'South','Karnataka','REV02','Accurate and on time'),
('NX-2024-007','ENT007','Eastern Gramin Bank','SLR','CSV','2024-01-31','2024-02-03','RBI','Delayed',10000,'East','Odisha','REV01','Minor delay'),
('NX-2024-008','ENT008','Himalayan Micro Finance','DCCO','Excel','2024-04-30','2024-04-29','RBI','On Time',0,'North','Himachal Pradesh','REV03','Submitted early'),
('NX-2024-009','ENT009','Coastal General Insurance','FRL','PDF','2024-04-30','2024-05-02','IRDAI','Delayed',5000,'South','Kerala','REV04','Minimal delay'),
('NX-2024-010','ENT010','Capital Edge NBFC','ALM','Manual','2024-04-30',NULL,'RBI','Missed',500000,'West','Gujarat','REV02','No submission received'),
('NX-2024-011','ENT011','Pioneer Rural Bank','CRR','Excel','2023-10-31','2023-10-31','RBI','On Time',0,'Central','Madhya Pradesh','REV01','Compliant'),
('NX-2024-012','ENT012','Indus Valley NBFC','SLR','CSV','2023-10-31','2023-11-08','RBI','Delayed',30000,'West','Rajasthan','REV03','Week delay, warned'),
('NX-2024-013','ENT013','Metro Life Assurance','CSR','PDF','2024-04-30','2024-04-27','IRDAI','On Time',0,'West','Maharashtra','REV04','Early and complete'),
('NX-2024-014','ENT014','Sunrise Gramin MFI','FLR','Excel','2024-04-30','2024-04-30','RBI','On Time',0,'West','Maharashtra','REV01','On schedule'),
('NX-2024-015','ENT015','Tamil Cooperative Bank','ALM','Excel','2024-04-30','2024-05-01','RBI','Delayed',1000,'South','Tamil Nadu','REV02','One day late'),
('NX-2024-016','ENT016','North Star Finance','DCCO','CSV','2024-04-30','2024-04-30','RBI','On Time',0,'North','Punjab','REV03','Perfect record'),
('NX-2024-017','ENT017','Ganga Valley Bank','SLR','Excel','2024-01-31','2024-02-05','RBI','Delayed',12000,'North','Uttarakhand','REV04','5 days late'),
('NX-2024-018','ENT018','South Bay Microfinance','CRR','Manual','2024-01-31',NULL,'RBI','Missed',200000,'South','Andhra Pradesh','REV01','Repeat defaulter'),
('NX-2024-019','ENT019','West Coast Insurance','FRL','PDF','2024-01-31','2024-01-30','IRDAI','On Time',0,'West','Gujarat','REV02','Submitted a day early'),
('NX-2024-020','ENT020','Central India NBFC','ALM','Excel','2024-04-30','2024-05-15','RBI','Delayed',75000,'Central','Chhattisgarh','REV03','15 day delay, penalty applied');
