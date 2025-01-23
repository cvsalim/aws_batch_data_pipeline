# aws_batch_data_pipeline
This is a hands on project for a batch data pipeline for music streams building in AWS

Tools and solutions: AWS Airflow, AWS Redshift, python scripts, terraform

Solution Architecture

![Databatcharc](https://github.com/user-attachments/assets/845d8588-0d73-4c8c-8f23-073824d64176)

Description
The solution seeks starting on validation of datasets in S3 buckets, check the validation, calculate genre level and move the files to redshift tables.
This solution is composed by the following steps:
IAC Deploymment
    -1 In your terminal, make sure you are in the terraform path
    -2 Initialize Terraform with: terraform init
    -3 Validate terraform: terraform validate 
    -4 Plan the deploymment: terraform plan
    -5 Apply: terraform apply 
    Note: Ensure you have terraform, AWS CLI configured and IAM permissions

Landing
    -1 Create an IAM role with S3 read/write permissions and attach it to the Redshift cluster
    -2 Create a bucket and save the data_source in a table

Orchestration
    -1 Create an Airflow environment and add the DAG in the folder airflow_dags

Data Warehouse
    - Create the dataset by running the redshift-tables.sql in the folder redshift

*Make sure you have changed the scripts according to your account and environment values