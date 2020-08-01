CREATE DATABASE SEC_Info;

USE SEC_Info;

CREATE TABLE Form (
  form char(15) NOT NULL,
  form_desc char(200) DEFAULT NULL,
  PRIMARY KEY (form)
);

CREATE TABLE Industry (
  sic int(11) NOT NULL,
  industry_desc text,
  PRIMARY KEY (sic)
);

CREATE TABLE Company (
  cik int(11) NOT NULL,
  name char(100) DEFAULT NULL,
  sic int(11) DEFAULT NULL,
  address char(200) DEFAULT NULL,
  phone char(30) DEFAULT NULL,
  state_inc char(20) DEFAULT NULL,
  PRIMARY KEY (cik),
  FOREIGN KEY (sic) REFERENCES Industry (sic) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Filing (
  accession char(30) NOT NULL,
  cik int(11) NOT NULL,
  filing_date char(15) DEFAULT NULL,
  form char(15) DEFAULT NULL,
  PRIMARY KEY (accession,cik),
  FOREIGN KEY (cik) REFERENCES Company (cik) ON DELETE CASCADE,
  FOREIGN KEY (form) REFERENCES Form (form) ON DELETE CASCADE
);



