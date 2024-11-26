from dagster import schedule
from my_project.jobs.replication_job import replication_job

@schedule(cron_schedule="0 9 * * *", job=replication_job, execution_timezone="UTC")
def daily_replication_schedule():
    return {}