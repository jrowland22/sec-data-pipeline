
-- stores data about companies
CREATE TABLE IF NOT EXISTS company (
	cik int,
	name char(40))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/hadoop/Company/part-m-00000' OVERWRITE INTO TABLE company;

-- stores data related to filings made by companies
CREATE TABLE IF NOT EXISTS filing (
	accession char(20),
	cik int,
	filing_date date,
	form char(20))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

LOAD DATA INPATH '/user/hadoop/Filing/part-m-00000' OVERWRITE INTO TABLE filing;

-- stores all data from the original web log file
CREATE TABLE IF NOT EXISTS logs (
	ip_address char(15),
	access_date date,
	access_time char(10),
	time_zone int,
	cik int,
	accession char(25),
	extention char(50),
	code int,
	size int,
	idx int,
	norefer int,
	noagent int,
	find int,
	crawler int,
	browser char(5))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\N'
STORED AS TEXTFILE
TBLPROPERTIES ('skip.header.line.count'='1','serialization.null.format'=''); 

LOAD DATA INPATH '/user/hadoop/log20160101.csv' OVERWRITE INTO TABLE logs;

-- stores the processed logs
CREATE TABLE IF NOT EXISTS processed_logs(
	ip_address char(15),
	access_date date,
	access_time char(10),
	whole_time timestamp,
	cik int,
	accession char(25),
	extention char(50))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- converts date into timestamp, removes records that identify as a web crawler(crawler=1) or whose http status code is greater than or equal to 400. Also removes records whose IP appears more than 50 times for a given day.
INSERT INTO TABLE processed_logs 
SELECT ip_address,access_date, access_time, concat(access_date,' ',access_time),cik,accession,extention 
FROM logs
WHERE crawler = 0 and code < 400 and logs.ip_address IN (
	SELECT l.ip_address 
	FROM logs l
	GROUP BY l.ip_address 
	HAVING count(l.ip_address) < 50);

-- joins company information with filing information made by that company
CREATE TABLE filing_complete as 
	SELECT filing.cik, accession, filing_date,form,name 
	FROM filing, company 
	WHERE filing.cik = company.cik;

-- contains all information related to an ips request
CREATE TABLE base_table as 
	SELECT ip_address,access_date,whole_time,processed_logs.cik,processed_logs.accession,extention,filing_date,form,name
	FROM processed_logs, filing_complete 
	WHERE processed_logs.cik = filing_complete.cik and processed_logs.accession = filing_complete.accession;


-- stores filing_complete table temporarily in s3 bucket 
INSERT OVERWRITE DIRECTORY 's3://hive-output5/filings/' 
ROW FORMAT DELIMITED  
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
STORED AS TEXTFILE SELECT * FROM filing_complete;

-- stores base_table temporarily in s3 before being loaded into cassandra
INSERT OVERWRITE DIRECTORY 's3://hive-output5/logs/' 
ROW FORMAT DELIMITED  
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
STORED AS TEXTFILE SELECT * FROM base_table;

