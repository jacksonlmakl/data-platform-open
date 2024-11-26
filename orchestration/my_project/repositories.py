from dotenv import load_dotenv
import os

# Load environment variables from .env
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..../deployment/.env"))
print(dagster_home, "HELP")
# Ensure DAGSTER_HOME is set
dagster_home = os.getenv('DAGSTER_HOMEs')

if not dagster_home:
    raise ValueError("DAGSTER_HOME is not set in your .env file!")

os.environ['DAGSTER_HOME'] = os.path.abspath(dagster_home)
print(f"DAGSTER_HOME set to: {os.environ['DAGSTER_HOME']}")
