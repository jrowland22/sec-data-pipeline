# SEC Data Pipeline

## Introduction
The U.S. Securities and Exchange Commission (SEC) is a government agency that aims to protect investors by ensuring that companies are truthful and transparent to their investors about their business activities. This is done by requiring public companies to file certain forms with the SEC on a regular basis. Once a company submits a form to the SEC, the SEC disperses the information to the public via their website. This allows investors to go to the SEC website and research a company’s current and past business activities. Recently the SEC made their web logs dating back to 2003 and as recent as 2017 available as csv files to the public. Each log file contains data about all user requests for a given day. This project aims to create a batch processing data pipeline that runs once every day processing the log file from the previous day. In the end, this API will provide us with insights as to what companies, filings and forms users are interested in.
## Data Set
The log file contains the following attributes: ‘ip,date,time,zone,cik,accession,extention,code,size,idx,norefer,noagent,find,crawler’ 
The most important attributes for analysis of the log files being IP address, date, time, cik and accession. CIK stands for ‘Central Index Key’, it is a number assigned to a company to uniquely identify it. The issue with this is you would not know which company a user is researching without going to look up the CIK manually on the SEC website; therefore, more information about the company needs to be integrated. The accession number identifies a unique filing made by a company. But once again there is no information provided as to what company, form, or the date of the filing from the accession number alone. The data set also needs to be cleaned of bot requests so that analysis of the data only reflects human requests. A full description of attributes can be found [here](https://www.sec.gov/files/EDGAR_variables_FINAL.pdf)

Sample records:<br>
![image](https://github.com/jrowland22/sec-data-pipeline/blob/master/images/sec-sample.png)
## Technology
This pipeline was deployed fully on AWS using the following technologies:
- MySQL 8.0.17 (RDS)
- Sqoop 1.4.7 (EMR)
- Hive 2.3.6 (EMR)
- Cassandra 3.11.5 (EC2)

Pipeline Architecture:
<br>
<br>
![image](https://github.com/jrowland22/sec-data-pipeline/blob/master/images/pipeline.png)

## Running
### Set up MySQL in RDS
Start MySQL
```
mysql -u root --password=password
```
Create tables
```
source mysql/create_tables.sql
```
Load data into MySQL tables
```
source mysql/load_data.sql
```
### Configure and run Hive on EMR
Create a three node EMR cluster on AWS
<br>
<br>
Configure HDFS and run Sqoop
```
./hdfs/emr_setup.sh
```
Run Hive processing script
```
./hive/hive_processing.q
```
### Configure and run Cassandra
Run the following commands on each EC2
<br>
<br>
Install java
```
sudo yum install java-1.8.0-openjdk
```
Install cassandra
```
wget https://www-us.apache.org/dist/cassandra/3.11.5/apache-cassandra-3.11.5-bin.tar.gz
```
Extract cassandra
```
tar -zxf apache-cassandra-3.11.5-bin.tar.gz
```
Edit cassandra.yaml 
```
vim apache-cassandra-3.11.5/conf/cassandra.yaml
```
Change the following fields
```
seeds:”<node_2_private_ip>,<node_3_private_ip>”
endpoint: Ec2Snitch
rpc_address: <current_node_private_ip>
listen_address: <current_node_private_ip>
```
Repeat on each node and change the value of “seeds” to the other nodes that you are not currently on. Also change the values of “rpc_address” and “listen_address” to the current nodes IP.
<br>
<br>
Start Cassandra
```
./cassandra
```
Open a new terminal window and download hive tables from s3
```
wget https://<path_to_s3_file>
wget https://<path_to_s3_file>
```
Run the following to create the keyspace, tables and insert data into the tables
```
./Cassandra/cassandra_ddl.cql
```
Enter cqlsh
```
cqlsh <node_private_ip>
```
Enter the keyspace and proceed to run queries
```
USE logs;
```
