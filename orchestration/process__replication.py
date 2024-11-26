import subprocess
from dagster import job, op

@op
def run_replication_script():
    """
    Op to run the replication.py script using subprocess.
    """
    try:
        # Define the script path relative to the orchestration directory
        script_path = "../scripts/replication.py"

        # Execute the script
        result = subprocess.run(
            ["python3", script_path],
            capture_output=True,  # Captures stdout and stderr
            text=True             # Outputs as text instead of bytes
        )

        # Log the output and errors
        if result.returncode == 0:
            # Successful execution
            print("Script executed successfully!")
            print(f"Output:\n{result.stdout}")
        else:
            # Handle errors
            print("Error executing the script!")
            print(f"Return code: {result.returncode}")
            print(f"Error Output:\n{result.stderr}")
            raise Exception(f"Script failed with return code {result.returncode}")

    except Exception as e:
        # Handle any unexpected errors
        print(f"Failed to execute the script: {e}")
        raise

# Define a Dagster job that includes the operation
@job
def replication_job():
    run_replication_script()


if __name__ == "__main__":
    replication_job.execute_in_process()
