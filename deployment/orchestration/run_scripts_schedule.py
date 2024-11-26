from dagster import schedule
from orchestration.run_scripts_job import run_scripts_job

@schedule(cron_schedule="0 9 * * *", job=run_scripts_job, execution_timezone="UTC")
def daily_run_scripts_schedule():
    return {}
