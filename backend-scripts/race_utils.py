import requests
import json
from dateutil import parser
import datetime
import time
import traceback
import os

def get_race_start_time(session_key):
    """
    Fetches race control messages and determines the race start time
    based on the 'GREEN LIGHT - PIT EXIT OPEN' message that marks the actual race start.

    Args:
        session_key (int): The F1 session key (e.g., 9472)

    Returns:
        str: ISO format timestamp of race start time
    """
    print(f"[INFO] Fetching race control data for session {session_key}...")
    url = "https://api.openf1.org/v1/race_control_messages"
    params = {
        "session_key": session_key
    }

    try:
        response = requests.get(url, params=params)

        if response.status_code == 200:
            race_control_data = response.json()

            
            race_control_data.sort(key=lambda x: x.get("date", ""))

            
            green_light_messages = []
            for message in race_control_data:
                if (message.get("category") == "Flag" and
                        "GREEN LIGHT - PIT EXIT OPEN" in message.get("message", "")):
                    green_light_messages.append({
                        "date": message.get("date"),
                        "message": message.get("message")
                    })

            if len(green_light_messages) > 1:
                print(f"[INFO] Found {len(green_light_messages)} 'GREEN LIGHT' messages:")
                for i, msg in enumerate(green_light_messages):
                    print(f"  {i + 1}. {msg['date']} - {msg['message']}")


                start_time = green_light_messages[-1]["date"]

                
                is_race_start = False
                start_time_parsed = parser.isoparse(start_time)

                for message in race_control_data:
                    msg_time = parser.isoparse(message.get("date", ""))
                    
                    if (msg_time > start_time_parsed and
                            message.get("category") == "Drs" and
                            "DRS ENABLED" in message.get("message", "") and
                            (msg_time - start_time_parsed).total_seconds() < 300):  

                        is_race_start = True
                        break

                if is_race_start:
                    print(f"[SUCCESS] Race start time identified: {start_time}")
                    return start_time
                else:
                    
                    
                    print(
                        f"[WARNING] Could not confirm race start time with certainty. Using last GREEN LIGHT message: {start_time}")
                    return start_time

            elif len(green_light_messages) == 1:
                start_time = green_light_messages[0]["date"]
                print(f"[SUCCESS] Race start time identified: {start_time}")
                return start_time

            else:
                print("[WARNING] Could not find race start time from race control messages")
                
                for message in race_control_data:
                    if message.get("category") == "Drs" and "DRS ENABLED" in message.get("message", ""):
                        drs_time = message.get("date")
                        
                        drs_datetime = parser.isoparse(drs_time)
                        
                        estimated_start = (drs_datetime - datetime.timedelta(minutes=2)).isoformat()
                        print(f"[INFO] Estimated race start time based on DRS enabled: {estimated_start}")
                        return estimated_start

                
                print("[WARNING] Could not determine race start time. Using default reference time.")
                return "2024-03-02T15:03:42+00:00"  
        else:
            print(f"[ERROR] Failed to fetch race control data: {response.status_code}")
            return "2024-03-02T15:03:42+00:00"  
    except Exception as e:
        print(f"[ERROR] Exception while fetching race start time: {str(e)}")
        traceback.print_exc()
        return "2024-03-02T15:03:42+00:00"  


def calculate_relative_time(timestamp, reference_time):
    """
    Calculate the relative time in seconds from a reference time

    Args:
        timestamp (str): ISO format timestamp to convert to relative time
        reference_time (str): ISO format reference timestamp (race start time)

    Returns:
        float: Relative time in seconds
    """
    try:
        if timestamp is None:
            return 0

        current_time = parser.isoparse(timestamp)
        ref_time = parser.isoparse(reference_time)
        rel_time = (current_time - ref_time).total_seconds()
        return rel_time

    except Exception as e:
        print(f"[ERROR] Failed to calculate relative time: {str(e)}")
        return 0

def save_race_start_time(start_time, meeting_key=None):
    """
    Save the race start time to a file for reference

    Args:
        start_time (str): ISO format timestamp of race start
        meeting_key (int): Optional meeting key to organize data
    """
    
    if meeting_key:
        base_dir = os.path.join("F1_Data", str(meeting_key))
        if not os.path.exists(base_dir):
            os.makedirs(base_dir)
    else:
        base_dir = "."
    
    start_time_data = {
        "race_start_time": start_time,
        "timestamp": parser.isoparse(start_time).timestamp()
    }

    output_path = os.path.join(base_dir, "race_start_time.json")

    try:
        with open(output_path, 'w') as file:
            json.dump(start_time_data, file, indent=2)
        print(f"[SUCCESS] Race start time saved to {output_path}")
    except Exception as e:
        print(f"[ERROR] Failed to save race start time: {str(e)}")


def get_saved_race_start_time(meeting_key=None):
    """
    Get previously saved race start time if available

    Args:
        meeting_key (int): Optional meeting key to organize data

    Returns:
        str: ISO format timestamp of race start time or None if not found
    """
    if meeting_key:
        base_dir = os.path.join("F1_Data", str(meeting_key))
        file_path = os.path.join(base_dir, "race_start_time.json")
    else:
        file_path = "race_start_time.json"

    try:
        if os.path.exists(file_path):
            with open(file_path, 'r') as file:
                data = json.load(file)
                return data.get("race_start_time")
        return None
    except Exception as e:
        print(f"[ERROR] Failed to read saved race start time: {str(e)}")
        return None

if __name__ == "__main__":
    
    import sys

    if len(sys.argv) > 1:
        session_key = int(sys.argv[1])
    else:
        session_key = 9472  

    race_start_time = get_race_start_time(session_key)
    if race_start_time:
        print(f"Race start time: {race_start_time}")
        start_datetime = parser.isoparse(race_start_time)
        print(f"Parsed datetime: {start_datetime}")
        
        test_time = "2024-03-02T15:10:00+00:00"
        rel_time = calculate_relative_time(test_time, race_start_time)
        print(f"Relative time for {test_time}: {rel_time} seconds")