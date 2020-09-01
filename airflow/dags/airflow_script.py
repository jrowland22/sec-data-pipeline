import airflow
from datetime import timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.emr_add_steps import EmrAddStepsOperator
from airflow.providers.amazon.aws.operators.emr_create_job_flow import EmrCreateJobFlowOperator
from airflow.providers.amazon.aws.operators.emr_terminate_job_flow import EmrTerminateJobFlowOperator
from airflow.providers.amazon.aws.sensors.emr_step import EmrStepSensor


JOB_FLOW_OVERRIDES = {
    "Name": "batch-pipeline",
    "LogUri": "s3://<log_path>",
    "ReleaseLabel": "emr-5.30.1",
    "Applications":[
    {"Name": "Hive"},
    {"Name": "Hadoop"},
    {"Name": "Sqoop"}
    ],
    "Instances": {
        "InstanceGroups": [
            {
                "Name": "Master node",
                "Market": "ON_DEMAND",
                "InstanceRole": "MASTER",
                "InstanceType": "m4.large",
                "InstanceCount": 1
            },
            {                    
                "Name": "Slave node",
                "Market": "ON_DEMAND",
                "InstanceRole": "CORE",
                "InstanceType": "m4.large",
                "InstanceCount": 1
            }
        ],
        "KeepJobFlowAliveWhenNoSteps": False,
        "TerminationProtected": False,
        "Ec2KeyName": "<>",
        "Ec2SubnetId": "<>",
        "EmrManagedMasterSecurityGroup": "<>",
        "EmrManagedSlaveSecurityGroup": "<>"
    },
    "JobFlowRole": "EMR_EC2_DefaultRole",
    "ServiceRole": "EMR_DefaultRole"
}


default_args = {
	'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(0),
    'provide_context': True
}

step1 = [
{
  "Name": "Setup Hadoop configuration",
  "ActionOnFailure": "CONTINUE",
  "HadoopJarStep": {
    "Jar": "command-runner.jar",
    "Args": ["aws","s3","cp","s3://path/to/emr_setup.sh","/home/hadoop/"]
  }
}
]

step2 = [
{
  "Name": "Run",
  "ActionOnFailure": "CONTINUE",
  "HadoopJarStep": {
    "Jar": "command-runner.jar",
    "Args": ["bash","/home/hadoop/emr_setup.sh"]
  }
} 
]

dag = DAG(
    'sec-pipeline',
    default_args=default_args,
    description='DAG test',
    schedule_interval=timedelta(days=1),
)

create_emr_cluster = EmrCreateJobFlowOperator(
	task_id = 'create_job_flow',
	aws_conn_id = 'aws_default',
	emr_conn_id = 'emr_default',
	region_name = 'us-east-2',
	job_flow_overrides = JOB_FLOW_OVERRIDES,
	dag = dag
)

emr_step_1 = EmrAddStepsOperator(
	task_id = 'emr_step1',
	job_flow_id = "{{ task_instance.xcom_pull(task_ids='create_job_flow', key='return_value') }}",
	aws_conn_id = 'aws_default',
	steps = step1,
	dag = dag
)

emr_step_2 = EmrAddStepsOperator(
    task_id = 'emr_step2',
    job_flow_id = "{{ task_instance.xcom_pull(task_ids='create_job_flow', key='return_value') }}",
    aws_conn_id = 'aws_default',
    steps = step2,
    dag = dag
)

emr_step_sensor = EmrStepSensor(
    task_id = 'watch_step',
    job_flow_id = "{{ task_instance.xcom_pull('create_job_flow', key='return_value') }}",
    step_id = "{{ task_instance.xcom_pull(task_ids='emr_step2', key='return_value')[0] }}",
    aws_conn_id = 'aws_default',
    dag = dag
)

stop_emr_cluster = EmrTerminateJobFlowOperator(
	task_id = 'stop_emr1',
	job_flow_id = "{{ task_instance.xcom_pull(task_ids='create_job_flow', key='return_value') }}",
	aws_conn_id = 'aws_default',
	dag = dag
)

create_emr_cluster >> emr_step_1
emr_step_1 >> emr_step_2
emr_step_2 >> emr_step_sensor
emr_step_sensor >> stop_emr_cluster
