from dagster import Definitions
from orchestration.run_scripts_job import run_scripts_job
from orchestration.run_scripts_schedule import daily_run_scripts_schedule

defs = Definitions(
    jobs=[run_scripts_job],
    schedules=[daily_run_scripts_schedule],
)
