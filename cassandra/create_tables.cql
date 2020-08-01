CREATE KEYSPACE logs 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 3};

use logs;

CREATE TABLE forms (
	ip_address varchar,
	access_date date,
	whole_time timestamp,
	cik varchar,
	accession varchar,
	extention varchar,
	filing_date varchar,
	form varchar,
	name varchar,
PRIMARY KEY((form,access_date),ip_address,whole_time));

copy forms
from 'log.csv' 
with delimiter=',' and header = FALSE;


CREATE TABLE companies (
	ip_address varchar,
	access_date date,
	whole_time timestamp,
	cik varchar,
	accession varchar,
	extention varchar,
	filing_date varchar,
	form varchar,
	name varchar,
PRIMARY KEY((cik,access_date),ip_address,whole_time));

copy companies
from 'log.csv' 
with delimiter=',' and header = FALSE;


CREATE TABLE filings (
	ip_address varchar,
	access_date date,
	whole_time timestamp,
	cik varchar,
	accession varchar,
	extention varchar,
	filing_date varchar,
	form varchar,
	name varchar,
PRIMARY KEY((accession,access_date),ip_address,whole_time));

copy filings 
from 'log.csv' 
with delimiter=',' and header = FALSE;


-- table that stores details about filings made by a companies
CREATE TABLE filing_info (
	cik varchar, 
	accession varchar, 
	filing_date timestamp,
	form varchar,
	name varchar,
PRIMARY KEY (cik,filing_date,form));

copy filing_info
from 'filing.csv' with delimiter=',' and header = FALSE;

