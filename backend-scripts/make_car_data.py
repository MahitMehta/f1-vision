import requests
import json
import os
from dateutil import parser
import time
import traceback
import datetime
from make_location_data import get_driver_list
from race_utils import get_race_start_time, calculate_relative_time, save_race_start_time, get_saved_race_start_time

def make_car_data_file(session_key=9472, meeting_key=None):
    """
    Creates car_data files in the F1_Data/[meeting_key] directory

    Args:
        session_key (int): F1 session key to use for data fetching
        meeting_key (int): Optional meeting key to organize data (defaults to None)
    """
    print(f"[INFO] Starting car data fetch for session {session_key}")
    url = "https://api.openf1.org/v1/car_data"
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
        base_dir = "car_data"
    
    car_data_dir = os.path.join(base_dir, "car_data")
    if not os.path.exists(car_data_dir):
        os.makedirs(car_data_dir)
        print(f"[INFO] Created directory {car_data_dir}")
    
    if not os.path.exists(base_dir):
        os.makedirs(base_dir)
        print(f"[INFO] Created directory {base_dir}")
    
    combined_driver_data = []

    for driver_number in driver_numbers:
        positions = []
        local_params = params.copy()
        local_params["driver_number"] = driver_number

        try:
            response = requests.get(url, params=local_params)

            if response.status_code == 200:
                car_data = response.json()

                if car_data and len(car_data) > 0:
                    
                    if driver_number == driver_numbers[0]:
                        print(f"[DEBUG] Sample car data entry: {json.dumps(car_data[0], indent=2)}")

                    for entry in car_data:
                        position = []
                        
                        rel_time = calculate_relative_time(entry.get("date"), race_start_time)

                        position.append(rel_time)
                        position.append(entry.get("rpm", 0))
                        position.append(entry.get("speed", 0))
                        position.append(entry.get("n_gear", 0))
                        position.append(entry.get("throttle", 0))
                        position.append(entry.get("drs", 0))
                        position.append(entry.get("brake", 0))

                        positions.append(position)
                    print(f"[INFO] Driver {driver_number}: Fetched {len(positions)} telemetry points")
                else:
                    print(f"[INFO] Driver {driver_number}: No car data found")
            else:
                print(f"[ERROR] Failed fetching car data for driver {driver_number}: {response.status_code}")
        except Exception as e:
            print(f"[ERROR] Exception while fetching car data for driver {driver_number}: {str(e)}")
        
        if positions:
            driver_data = {
                "id": driver_number,
                "positions": positions,
            }

            combined_driver_data.append(driver_data)

            filename = f"{driver_number}.json"
            filepath = os.path.join(car_data_dir, filename)

            try:
                with open(filepath, 'w') as file:
                    json.dump(driver_data, file, separators=(',', ':'))  
                print(f"[INFO] Created {filepath} with {len(positions)} telemetry points")
            except Exception as e:
                print(f"[ERROR] Exception while writing {filepath}: {str(e)}")

        time.sleep(0.2)

    combined_path = os.path.join(base_dir, "car_data.json")
    try:
        with open(combined_path, 'w') as file:
            json.dump(combined_driver_data, file, separators=(',', ':'))  
        print(f"[SUCCESS] Created {combined_path} with data for {len(combined_driver_data)} drivers")
    except Exception as e:
        print(f"[ERROR] Exception while writing {combined_path}: {str(e)}")

    print(f"[SUCCESS] Created car data files in {car_data_dir} directory")
    return combined_driver_data

def flatten_car_data(input_file='car_data.json', output_file='new_car_data.json'):
    """
    Transforms car_data.json structure into a flat list of events sorted by relative time

    Args:
        input_file (str): Path to input car data JSON file
        output_file (str): Path to output flattened data JSON file
    """
    print(f"[INFO] Flattening car data from {input_file} to {output_file}")

    try:
        with open(input_file, 'r') as file:
            driver_data = json.load(file)

        events = []
        for driver in driver_data:
            driver_id = driver['id']
            for pos in driver['positions']:
                events.append({
                    "id": driver_id,
                    "rpm": pos[1],
                    "speed": pos[2],
                    "n_gear": pos[3],
                    "throttle": pos[4],
                    "drs": pos[5],
                    "brake": pos[6],
                    "rel_time": pos[0]
                })
        
        events.sort(key=lambda x: x['rel_time'])

        with open(output_file, "w") as f:
            json.dump(events, f)

        print(f"[SUCCESS] Created flattened car data file {output_file} with {len(events)} events")

    except Exception as e:
        print(f"[ERROR] Failed to flatten car data: {str(e)}")
        traceback.print_exc()

def split_car_data_by_driver(input_file='car_data.json', output_dir='new_car_data'):
    """
    Splits car_data.json into separate files for each driver

    Args:
        input_file (str): Path to input car data JSON file
        output_dir (str): Directory to output individual driver JSON files
    """
    print(f"[INFO] Splitting car data by driver from {input_file} to directory {output_dir}")

    try:
        with open(input_file, 'r') as file:
            driver_data = json.load(file)
        
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
            print(f"[INFO] Created directory {output_dir}")

        for driver in driver_data:
            driver_id = driver['id']
            filename = f"{driver_id}.json"
            output_path = os.path.join(output_dir, filename)

            with open(output_path, "w") as f:
                json.dump(driver, f)

            print(f"[INFO] Created {filename} with {len(driver['positions'])} data points")

        print(f"[SUCCESS] Split car data for {len(driver_data)} drivers into {output_dir}")

    except Exception as e:
        print(f"[ERROR] Failed to split car data by driver: {str(e)}")
        traceback.print_exc()

if __name__ == "__main__":
    import os
    import traceback

    make_car_data_file(9693)

    
    
    