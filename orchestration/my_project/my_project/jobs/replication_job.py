from dagster import job
from my_project.ops.replication_op import run_replication_script

@job
def replication_job():
    run_replication_script()
