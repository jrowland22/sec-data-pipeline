#!bin/bash

pip install apache-airflow-backport-providers-amazon

cp /sec-data-pipeline-master/airflow/dags/airflow_script.py ~/airflow/dags/

airflow initdb

airflow scheduler

airflow trigger_dag sec-pipeline