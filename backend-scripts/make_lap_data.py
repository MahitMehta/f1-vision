import requests
import json
import os
from dateutil import parser
import time
import traceback
import datetime
from make_location_data import get_driver_list
from race_utils import get_race_start_time, calculate_relative_time, save_race_start_time, get_saved_race_start_time

def make_lap_data_file(session_key=9472, meeting_key=None):
    """
    Creates lap_data.json with lap timing data

    Args:
        session_key (int): F1 session key to use for data fetching
        meeting_key (int): Optional meeting key to organize data (defaults to None)
    """
    print(f"[INFO] Starting lap data fetch for session {session_key}")
    url = "https://api.openf1.org/v1/laps"
    driver_numbers = get_driver_list(session_key)
    
    race_start_time = get_saved_race_start_time(meeting_key)
    if not race_start_time:
        race_start_time = get_race_start_time(session_key)
        if race_start_time:
            save_race_start_time(race_start_time, meeting_key)

    print(f"[INFO] Using race start time: {race_start_time}")

    params = {
        "session_key": session_key,
    }
    
    if meeting_key:
        
        base_dir = os.path.join("F1_Data", str(meeting_key))
    else:
        
        base_dir = "."
    
    if not os.path.exists(base_dir):
        os.makedirs(base_dir)
        print(f"[INFO] Created directory {base_dir}")

    driver_data_list = []
    
    for driver_number in driver_numbers:
        positions = []
        local_params = params.copy()
        local_params["driver_number"] = driver_number

        try:
            response = requests.get(url, params=local_params)

            if response.status_code == 200:
                driver_data = response.json()

                if driver_data and len(driver_data) > 0:
                    
                    if driver_number == driver_numbers[0]:
                        print(f"[DEBUG] Sample lap entry: {json.dumps(driver_data[0], indent=2)}")

                    for entry in driver_data:
                        lap_data = []
                        
                        lap_data.append(entry.get("lap_number", 0))
                        
                        lap_data.append(entry.get("duration_sector_1", 0))
                        lap_data.append(entry.get("duration_sector_2", 0))
                        lap_data.append(entry.get("duration_sector_3", 0))
                        
                        lap_data.append(entry.get("lap_duration", 0))
                        
                        rel_time = calculate_relative_time(entry.get("date_start"), race_start_time)
                        lap_data.append(rel_time)

                        positions.append(lap_data)
                    print(f"[INFO] Driver {driver_number}: Fetched {len(positions)} laps")
                else:
                    print(f"[INFO] Driver {driver_number}: No lap data found")
            else:
                print(f"[ERROR] Failed fetching lap data for driver {driver_number}: {response.status_code}")
        except Exception as e:
            print(f"[ERROR] Exception while fetching lap data for driver {driver_number}: {str(e)}")

        driver_data_list.append({
            "id": driver_number,
            "positions": positions
        })

        time.sleep(0.2)

    output_path = os.path.join(base_dir, "lap_data.json")

    print(f"[INFO] Writing lap data to file...")
    try:
        with open(output_path, 'w') as file:
            json.dump(driver_data_list, file, separators=(',', ':'))  

        print(f"[SUCCESS] {output_path} file created successfully")
    except Exception as e:
        print(f"[ERROR] Exception while writing {output_path}: {str(e)}")

    return driver_data_list

def flatten_lap_data_to_events(input_file='lap_data.json', output_file='new_lap_data.json'):
    """
    Transforms lap_data.json structure into a flat list of lap and sector events sorted by relative time

    Args:
        input_file (str): Path to input lap data JSON file
        output_file (str): Path to output flattened data JSON file
    """
    print(f"[INFO] Flattening lap data from {input_file} to {output_file}")

    try:
        with open(input_file, 'r') as file:
            lap_data = json.load(file)

        events = []

        for lap in lap_data:
            driver = lap['id']
            for pos in lap['positions']:
                
                lap_num = pos[0] if len(pos) > 0 else 0
                sector1_time = pos[1] if len(pos) > 1 else 0
                sector2_time = pos[2] if len(pos) > 2 else 0
                sector3_time = pos[3] if len(pos) > 3 else 0
                total_lap_time = pos[4] if len(pos) > 4 else 0
                rel_time_at_lap_start = pos[5] if len(pos) > 5 else 0
                
                events.append({
                    "type": "lap_start",
                    "id": driver,
                    "lap": lap_num,
                    "rel_time": rel_time_at_lap_start,
                })
                
                events.append({
                    "type": "sector",
                    "id": driver,
                    "lap": lap_num,
                    "sector": 1,
                    "sector_time": sector1_time,
                    "rel_time": round(rel_time_at_lap_start + sector1_time, 3)
                })

                events.append({
                    "type": "sector",
                    "id": driver,
                    "lap": lap_num,
                    "sector": 2,
                    "sector_time": sector2_time,
                    "rel_time": round(rel_time_at_lap_start + sector1_time + sector2_time, 3)
                })
                
                events.append({
                    "type": "sector",
                    "id": driver,
                    "lap": lap_num,
                    "sector": 3,
                    "sector_time": sector3_time,
                    "rel_time": round(rel_time_at_lap_start + sector1_time + sector2_time + sector3_time, 3)
                })

                events.append({
                    "type": "lap_end",
                    "id": driver,
                    "lap": lap_num,
                    "lap_time": total_lap_time,
                    "rel_time": round(rel_time_at_lap_start + total_lap_time, 3)
                })
        
        events.sort(key=lambda x: x['rel_time'])

        with open(output_file, "w") as f:
            json.dump(events, f)

        print(f"[SUCCESS] Created flattened lap data file {output_file} with {len(events)} events")

    except Exception as e:
        print(f"[ERROR] Failed to flatten lap data: {str(e)}")
        import traceback
        traceback.print_exc()

def split_lap_data_by_driver(input_file='lap_data.json', output_dir='new_lap_data'):
    """
    Splits lap_data.json into separate files for each driver

    Args:
        input_file (str): Path to input lap data JSON file
        output_dir (str): Directory to output individual driver JSON files
    """
    print(f"[INFO] Splitting lap data by driver from {input_file} to directory {output_dir}")

    try:
        with open(input_file, 'r') as file:
            lap_data = json.load(file)
        
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
            print(f"[INFO] Created directory {output_dir}")
        
        for driver in lap_data:
            driver_id = driver['id']
            filename = f"driver_{driver_id}_laps.json"
            output_path = os.path.join(output_dir, filename)

            with open(output_path, "w") as f:
                json.dump(driver, f)

            print(f"[INFO] Created {filename} with {len(driver['positions'])} laps")

        print(f"[SUCCESS] Split lap data for {len(lap_data)} drivers into {output_dir}")

    except Exception as e:
        print(f"[ERROR] Failed to split lap data by driver: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    import os

    make_lap_data_file(9693)

    
    
    