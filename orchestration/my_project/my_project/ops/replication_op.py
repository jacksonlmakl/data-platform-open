import subprocess
from dagster import op

@op
def run_replication_script():
    """
    Op to execute the ...../scripts/replication.py script.
    """
    try:
        script_path = "...../scripts/replication.py"

        # Run the script
        result = subprocess.run(
            ["python3", script_path],
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            print("Replication script executed successfully.")
            print(f"Output:\n{result.stdout}")
        else:
            print(f"Error executing the replication script.\nError Output:\n{result.stderr}")
            raise Exception("Replication script failed.")

    except Exception as e:
        raise Exception(f"Error running replication script: {e}")
