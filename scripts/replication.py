import pandas as pd
import boto3
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../deployment/.env"))

# Fetch environment variables
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
print(AWS_ACCESS_KEY_ID,S3_BUCKET_NAME)
# Validate environment variables
if not all([AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, S3_BUCKET_NAME]):
    raise ValueError("One or more environment variables are missing!")

def upload_dict_as_parquet(data_dict, bucket_name, file_name, aws_access_key, aws_secret_access_key):
    """
    Uploads a dictionary as a .parquet file to an S3 bucket.

    :param data_dict: Dictionary containing the data to upload.
    :param bucket_name: Name of the S3 bucket.
    :param file_name: Name of the .parquet file to be created and uploaded.
    :param aws_access_key: AWS access key ID.
    :param aws_secret_access_key: AWS secret access key.
    """
    try:
        # Validate inputs
        if not all([data_dict, bucket_name, file_name, aws_access_key, aws_secret_access_key]):
            raise ValueError("One or more required parameters are missing!")

        # Convert dictionary to pandas DataFrame
        df = pd.DataFrame(data_dict)

        # Save DataFrame to a local .parquet file
        local_file = f"/tmp/{file_name}"
        df.to_parquet(local_file, engine='pyarrow', index=False)

        # Upload the file to S3
        s3 = boto3.client(
            's3',
            aws_access_key_id=aws_access_key,
            aws_secret_access_key=aws_secret_access_key
        )
        s3.upload_file(local_file, bucket_name, file_name)

        print(f"Successfully uploaded {file_name} to bucket {bucket_name}")

        # Clean up the local file
        os.remove(local_file)

    except Exception as e:
        print(f"Error uploading file: {e}")

# Example usage
if __name__ == "__main__":
    # Example dictionary
    data = {
        "name": ["Alice", "Bob", "Charlie"],
        "age": [25, 30, 35],
        "city": ["New York", "Los Angeles", "Chicago"]
    }

    # Upload the dictionary as a .parquet file
    upload_dict_as_parquet(
        data_dict=data,
        bucket_name=S3_BUCKET_NAME,
        file_name="example.parquet",
        aws_access_key=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    )

