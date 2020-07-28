# SEC Data Pipeline

## Introduction
The U.S. Securities and Exchange Commission (SEC) is a government agency that aims to protect investors by ensuring that companies are truthful and transparent to their investors about their business activities. This is done by requiring public companies to file certain forms with the SEC on a regular basis. Once a company submits a form to the SEC, the SEC disperses the information to the public via their website. This allows investors to go to the SEC website and research a company’s current and past business activities. Recently the SEC made their web logs dating back to 2003 and as recent as 2017 available as csv files to the public. Each log file contains data about all user requests for a given day. This project implements a batch processing data pipeline that runs once every day processing the log file from the previous day. This project allows researchers to effectively study the statistics and demand for financial records made by investors/potential investors. 
## Data Set
The log file contains the following attributes: ‘ip,date,time,zone,cik,accession,extention,code,size,idx,norefer,noagent,find,crawler’ 
The most important attributes for analysis of the log files being IP address, date, time, cik and accession. CIK stands for ‘Central Index Key’, it is a number assigned to a company to uniquely identify it. The issue with this is you would not know which company a user is researching without going to look up the CIK manually on the SEC website; therefore, more information about the company needs to be integrated. The accession number identifies a unique filing made by a company. But once again there is no information provided as to what company, form, or the date of the filing from the accession number alone. The data set also needs to be cleaned of bot requests so that analysis of the data only reflects human requests.

Sample record:<br>
ip,date,time,zone,cik,accession,extention,code,size,idx,norefer,noagent,find,crawler <br>
100.43.81.bbb,2016-01-01,00:00:00,0.0,857737.0,0001564590-15-010715,icon-20150930_cal.xml,200.0,5194.0,0.0,0.0,0.0,10.0,0.0
## Technology
This pipeline was deployed fully on AWS using the following technologies
- MySQL (RDS)
- Sqoop (EMR)
- Hive (EMR)
- Cassandra (Ec2)

Pipeline Architecture:
![image](https://github.com/jrowland22/sec-data-pipeline/blob/master/images/pipeline.png)

## Running
Start mysql
```
mysql -u root --password=password
```
Create tables
```
source mysql/create_tables.sql
```
Load data into mysql tables
```
source mysql/load_data.sql
```
Create a three node emr cluster on AWS

Configure HDFS and run sqoop
```
./hdfs/emr_setup.sh
```
Run hive script
```
./hive/hive_processing.q
```
Configure cassandra cluster with three Ec2 instances
Run on each instance
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
Start Cassandra
```
./cassandra
```
Open a new terminal window and download hive tables from s3
```
wget https://<path_to_s3_file>
wget https://<path_to_s3_file>
```
Run the following to create key space, tables and insert data into tables
```
./Cassandra/cassandra_ddl.cql
```
To enter and run queries
```
cqlsh <node_private_ip>
```
Enter the keyspace
```
USE logs;
```
