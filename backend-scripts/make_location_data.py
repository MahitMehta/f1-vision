import requests
import json
import os
from dateutil import parser
import time
import traceback
from race_utils import get_race_start_time, calculate_relative_time, save_race_start_time, get_saved_race_start_time
import  datetime

def get_driver_list(session_key):
    """
    Fetches the list of drivers for the specified session
    """
    print(f"[INFO] Fetching drivers list for session {session_key}...")
    url = "https://api.openf1.org/v1/drivers"
    params = {
        "session_key": session_key
    }

    try:
        response = requests.get(url, params=params)

        if response.status_code == 200:
            drivers_data = response.json()
            driver_numbers = [driver["driver_number"] for driver in drivers_data]

            print(f"[SUCCESS] Found {len(driver_numbers)} drivers in session {session_key}")
            return driver_numbers
        else:
            print(f"[ERROR] Failed to fetch driver list: {response.status_code}")
            
            return [81, 1, 11, 16, 63, 55, 14, 4, 44, 27, 22, 18, 23, 3, 20, 77, 24, 2, 31, 10]
    except Exception as e:
        print(f"[ERROR] Exception while fetching driver list: {str(e)}")
        return [81, 1, 11, 16, 63, 55, 14, 4, 44, 27, 22, 18, 23, 3, 20, 77, 24, 2, 31, 10]

def make_location_data_file(session_key=9472, meeting_key=None):
    """
    Creates location_data.json with position data from the location endpoint

    Args:
        session_key (int): F1 session key to use for data fetching
        meeting_key (int): Optional meeting key to organize data (defaults to None)
    """
    print(f"[INFO] Starting location data fetch for session {session_key}")
    url = "https://api.openf1.org/v1/location"  
    driver_numbers = get_driver_list(session_key)

    
    race_start_time = get_saved_race_start_time(meeting_key)
    if not race_start_time:
        race_start_time = get_race_start_time(session_key)
        if race_start_time:
            save_race_start_time(race_start_time, meeting_key)

    print(f"[INFO] Using race start time: {race_start_time}")
    
    start_time_obj = parser.isoparse(race_start_time)
    
    time_before_start = "5m"  
    time_after_start = "3h"  

    before_start = (start_time_obj - datetime.timedelta(minutes=5)).isoformat()
    after_start = (start_time_obj + datetime.timedelta(hours=3)).isoformat()

    params = {
        "session_key": session_key,
        "date>": before_start,
        "date<": after_start,
    }

    if meeting_key:
        
        base_dir = os.path.join("F1_Data", str(meeting_key))
    else:
        
        base_dir = "."

    if not os.path.exists(base_dir):
        os.makedirs(base_dir)
        print(f"[INFO] Created directory {base_dir}")

    location_data_dict = []
    
    for driver_number in driver_numbers:
        positions = []
        local_params = params.copy()
        local_params["driver_number"] = driver_number

        try:
            response = requests.get(url, params=local_params)

            if response.status_code == 200:
                location_data = response.json()

                if location_data and len(location_data) > 0:
                    
                    if driver_number == driver_numbers[0]:
                        print(f"[DEBUG] Sample location entry: {json.dumps(location_data[0], indent=2)}")

                    for entry in location_data:
                        position = []
                        
                        position.append(entry.get("x", 0))
                        position.append(entry.get("y", 0))
                        position.append(entry.get("z", 0))

                        
                        rel_time = calculate_relative_time(entry.get("date"), race_start_time)
                        position.append(rel_time)

                        positions.append(position)

                print(f"[INFO] Driver {driver_number}: Fetched {len(positions)} location records")
            else:
                print(f"[ERROR] Failed fetching location data for driver {driver_number}: {response.status_code}")
        except Exception as e:
            print(f"[ERROR] Exception while fetching location data for driver {driver_number}: {str(e)}")

        location_data_dict.append({
            "id": driver_number,
            "positions": positions,
        })
        
        time.sleep(0.2)

    output_path = os.path.join(base_dir, "location_data.json")

    print(f"[INFO] Writing location data to file...")
    try:
        with open(output_path, 'w') as file:
            json.dump(location_data_dict, file, separators=(',', ':'))  

        print(f"[SUCCESS] {output_path} file created successfully")
    except Exception as e:
        print(f"[ERROR] Exception while writing {output_path}: {str(e)}")

    return location_data_dict

def flatten_location_position_data(input_file='location_data.json', output_file='new_location_data.json'):
    """
    Transforms location_data.json structure into a flat list of position events sorted by relative time

    Args:
        input_file (str): Path to input location data JSON file
        output_file (str): Path to output flattened data JSON file
    """
    print(f"[INFO] Flattening location position data from {input_file} to {output_file}")

    try:
        with open(input_file, 'r') as file:
            location_data = json.load(file)

        events = []
        for driver in location_data:
            driver_id = driver['id']
            for pos in driver['positions']:
                
                x = pos[0] if len(pos) > 0 else 0
                y = pos[1] if len(pos) > 1 else 0
                z = pos[2] if len(pos) > 2 else 0
                rel_time = pos[3] if len(pos) > 3 else 0

                events.append({
                    "id": driver_id,
                    "x": x,
                    "y": y,
                    "z": z,
                    "rel_time": rel_time
                })

        
        events.sort(key=lambda x: x['rel_time'])

        with open(output_file, "w") as f:
            json.dump(events, f)

        print(f"[SUCCESS] Created flattened position data file {output_file} with {len(events)} position points")

    except Exception as e:
        print(f"[ERROR] Failed to flatten location position data: {str(e)}")
        import traceback
        traceback.print_exc()

def split_location_data_by_driver(input_file='location_data.json', output_dir='new_location_data'):
    """
    Splits location_data.json into separate files for each driver

    Args:
        input_file (str): Path to input location data JSON file
        output_dir (str): Directory to output individual driver JSON files
    """
    print(f"[INFO] Splitting location data by driver from {input_file} to directory {output_dir}")

    try:
        with open(input_file, 'r') as file:
            location_data = json.load(file)

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
            print(f"[INFO] Created directory {output_dir}")
        
        for driver in location_data:
            driver_id = driver['id']
            filename = f"driver_{driver_id}_positions.json"
            output_path = os.path.join(output_dir, filename)

            with open(output_path, "w") as f:
                json.dump(driver, f)

            print(f"[INFO] Created {filename} with {len(driver['positions'])} position points")

        print(f"[SUCCESS] Split location data for {len(location_data)} drivers into {output_dir}")

    except Exception as e:
        print(f"[ERROR] Failed to split location data by driver: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    import os

    make_location_data_file(9693)

    
    
    