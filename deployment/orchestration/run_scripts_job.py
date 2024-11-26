from dagster import job, op
import subprocess
import os

@op
def run_all_scripts():
    """
    Op to execute all Python scripts in the scripts directory.
    """
    scripts_dir = os.path.abspath("./scripts")
    for script in os.listdir(scripts_dir):
        if script.endswith(".py"):
            script_path = os.path.join(scripts_dir, script)
            print(f"Running script: {script_path}")
            result = subprocess.run(
                ["python3", script_path],
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                raise Exception(f"Script {script} failed: {result.stderr}")
            print(f"Output for {script}:\n{result.stdout}")

@job
def run_scripts_job():
    run_all_scripts()
