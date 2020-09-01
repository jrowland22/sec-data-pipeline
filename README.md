# SEC Data Pipeline
## Introduction
The U.S. Securities and Exchange Commission (SEC) is a government agency that aims to protect investors by ensuring that companies are truthful and transparent to their investors about their business activities. This is done by requiring public companies to file certain forms with the SEC on a regular basis. Once a company submits a form to the SEC, the SEC disperses the information to the public via their website. This allows investors to go to the SEC website and research a company’s current and past business activities. Recently the SEC made their web logs dating back to 2003 and as recent as 2017 available as csv files to the public. Each log file contains data about all user requests for a given day. This project creates a batch processing data pipeline that runs once every day processing the log file from the previous day. In the end, this pipeline will provide us with insights as to what companies, filings and forms users are interested in.
## Data Set
The log file contains the following attributes: ‘ip,date,time,zone,cik,accession,extention,code,size,idx,norefer,noagent,find,crawler’ 
The most important attributes for analysis of the log files being IP address, date, time, cik and accession. CIK stands for ‘Central Index Key’, it is a number assigned to a company to uniquely identify it. The issue with this is you would not know which company a user is researching without going to look up the CIK manually on the SEC website; therefore, more information about the company needs to be integrated. The accession number identifies a unique filing made by a company. But once again there is no information provided as to what company, form, or the date of the filing from the accession number alone. The data set also needs to be cleaned of bot requests so that analysis of the data only reflects human requests. A full description of attributes can be found [here](https://www.sec.gov/files/EDGAR_variables_FINAL.pdf)

Sample records:<br>
![image](https://github.com/jrowland22/sec-data-pipeline/blob/master/images/sec-sample.png)
## Technology
This pipeline was deployed fully on AWS using the following technologies:
- Airflow 1.10.12 (EC2)
- MySQL 8.0.17 (RDS)
- Sqoop 1.4.7 (EMR)
- Hadoop 2.8.5 (EMR)
- Hive 2.3.6 (EMR)
- Athena (Serverless)

Pipeline Architecture:
<br>
<br>
![image](https://github.com/jrowland22/sec-data-pipeline/blob/master/images/sec-pipeline.png)

## Running
### Set up MySQL in RDS
Start MySQL
```
mysql -h <rds_endpoint> -P 3306 -u <user> --local-infile -p
```
Create tables
```
source /sec-data-pipeline-master/mysql/create_tables.sql
```
Load data into MySQL tables
```
source /sec-data-pipeline-master/mysql/load_data.sql
```
### Configure
Edit the following configuration files
```
- /airflow/dags/config.py
- /hdfs/emr.config
```
### Files to upload to S3
```
- /hdfs/emr_setup.sh
- /hive/hive_processing.q
```
### Airflow
Start airflow webserver
```
airflow webserver
```
Open UI and navigate to: Admin -> Connections -> aws_default <br>
Edit the following properties
```
Login: aws_access_key
Password: aws_secret_access_key
Extra: {"region_name":"your-region"}
```
Start airflow and trigger DAG
```
bash /airflow/start-airflow.sh
```
