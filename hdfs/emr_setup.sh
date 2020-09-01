#!/bin/bash

source emr.config

wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz. 

tar -xzf mysql-connector-java-5.1.48.tar.gz

sudo cp mysql-connector-java-5.1.48/mysql-connector-java-5.1.48-bin.jar /usr/lib/sqoop/

sqoop import --connect jdbc:mysql://$rds_endpoint/$rds_dbname --username $rds_user --password $rds_pass --table Filing --target-dir /user/hadoop/Filing -m 1

sqoop import --connect jdbc:mysql://$rds_endpoint/$rds_dbname --username $rds_user --password $rds_pass --table Company --columns 'cik,name' --target-dir /user/hadoop/Company -m 1

hadoop dfs -ls /user/hadoop/Filing

hadoop dfs -ls /user/hadoop/Company

wget http://www.sec.gov/dera/data/Public-EDGAR-log-file-data/2016/Qtr1/log20160101.zip

unzip log20160101.zip

hadoop fs -put log20160101.csv /user/hadoop/
