#!/usr/bin/env python3
"""Script to log Git commits within a specific date range."""

import os
import subprocess
from datetime import datetime, timedelta
from pathlib import Path


def main():
    # Get the directory where the script is located
    script_dir = Path(__file__).parent.resolve()

    # Set the working directory to the parent directory of the script's directory
    working_dir = script_dir.parent
    os.chdir(working_dir)

    # Define the start date and end date (tomorrow's date)
    start_date = "2024-10-01"  # Adjust the start date as needed
    end_date = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")

    # Print the date range
    print(f"Fetching commits from {start_date} to {end_date}")

    # Define output filename
    output_file = f"commit_details_{start_date}-{end_date}.log"

    # Run the Git log command with the date range filter
    try:
        result = subprocess.run(
            [
                "git", "log",
                f"--since={start_date}",
                f"--until={end_date}",
                "--pretty=format:%H %s%n%b"
            ],
            capture_output=True,
            text=True,
            check=True
        )

        # Write output to file
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(result.stdout)

        # Check if file has content
        if os.path.exists(output_file):
            if os.path.getsize(output_file) > 0:
                print("Commits have been logged successfully.")
            else:
                print("No commits found in the specified date range.")
        else:
            print("Failed to create the commit details file.")

    except subprocess.CalledProcessError as e:
        print(f"Git command failed: {e.stderr}")
    except FileNotFoundError:
        print("Git is not installed or not in PATH.")


if __name__ == "__main__":
    main()
