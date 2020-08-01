USE SEC_Info;

LOAD DATA LOCAL INFILE 'data/Company.csv'
INTO TABLE Company
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/Filing.csv'
INTO TABLE Filing
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/Form.csv'
INTO TABLE Form
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/Industry.csv'
INTO TABLE Industry
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;