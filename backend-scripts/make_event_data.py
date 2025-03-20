import os
import requests
import json
import traceback
from dateutil import parser
import time
import datetime
from make_location_data import get_driver_list
from race_utils import get_race_start_time, calculate_relative_time, save_race_start_time, get_saved_race_start_time

def make_event_data_file(session_key=9472, meeting_key=None):
    """
    Creates event_data.json with various race events

    Args:
        session_key (int): F1 session key to use for data fetching
        meeting_key (int): Optional meeting key for metadata (session_key is used for folder structure)
    """
    print(f"[INFO] Starting event data fetch for session {session_key}")

    
    race_start_time = get_saved_race_start_time(meeting_key, session_key)
    if not race_start_time:
        race_start_time = get_race_start_time(session_key)
        if race_start_time:
            save_race_start_time(race_start_time, meeting_key, session_key)

    print(f"[INFO] Using race start time: {race_start_time}")

    driver_numbers = get_driver_list(session_key)
    events = []
    
    base_dir = os.path.join("F1_Data", str(session_key))
    
    if not os.path.exists(base_dir):
        os.makedirs(base_dir)
        print(f"[INFO] Created directory {base_dir}")

    try:
        lap_data_path = os.path.join(base_dir, "lap_data.json")
        print(f"[INFO] Attempting to read {lap_data_path}...")
        with open(lap_data_path, 'r') as f:
            lap_data = json.load(f)

        print(f"[INFO] Processing lap data for events...")
        lap_events_count = 0
        for driver_data in lap_data:
            driver_id = driver_data.get('id', 0)
            laps = driver_data.get('positions', [])

            for lap in laps:
                if len(lap) >= 6:  
                    
                    lap_number = lap[0] if lap[0] is not None else 0
                    sector_1_duration = lap[1] if lap[1] is not None else 0
                    sector_2_duration = lap[2] if lap[2] is not None else 0
                    sector_3_duration = lap[3] if lap[3] is not None else 0
                    lap_duration = lap[4] if lap[4] is not None else 0
                    rel_start = lap[5] if lap[5] is not None else 0

                    
                    events.append({
                        'type': "Laps",
                        'time': rel_start + sector_1_duration,
                        'message': f"Driver {driver_id} completed sector 1 of lap {lap_number}"
                    })

                    events.append({
                        'type': "Laps",
                        'time': rel_start + sector_1_duration + sector_2_duration,
                        'message': f"Driver {driver_id} completed sector 2 of lap {lap_number}"
                    })

                    events.append({
                        'type': "Laps",
                        'time': rel_start + sector_1_duration + sector_2_duration + sector_3_duration,
                        'message': f"Driver {driver_id} completed sector 3 of lap {lap_number}"
                    })

                    events.append({
                        'type': "Laps",
                        'time': rel_start + lap_duration,
                        'message': f"Driver {driver_id} completed lap {lap_number}"
                    })
                    lap_events_count += 4

        print(f"[INFO] Added {lap_events_count} lap events")
    except FileNotFoundError:
        print(f"[WARNING] {lap_data_path} not found. Skipping lap events.")
    except Exception as e:
        print(f"[ERROR] Exception while processing lap data file: {str(e)}")
        traceback.print_exc()
    
    try:
        print(f"[INFO] Fetching pit stop data...")
        url = "https://api.openf1.org/v1/pit"
        params = {
            "session_key": session_key,
        }

        pit_count = 0
        for driver_number in driver_numbers:
            local_params = params.copy()
            local_params["driver_number"] = driver_number

            try:
                response = requests.get(url, params=local_params)

                if response.status_code == 200:
                    pit_data = response.json()

                    if pit_data and len(pit_data) > 0:
                        
                        if driver_number == driver_numbers[0] and len(pit_data) > 0:
                            print(f"[DEBUG] Sample pit entry: {json.dumps(pit_data[0], indent=2)}")

                        for pit in pit_data:
                            lap_number = pit.get("lap_number", 0)
                            
                            rel_time_in = calculate_relative_time(pit.get("date_of_pit_in"), race_start_time)
                            
                            if pit.get("date_of_pit_out"):
                                rel_time_out = calculate_relative_time(pit.get("date_of_pit_out"), race_start_time)
                            else:
                                rel_time_out = rel_time_in + 20

                            events.append({
                                'type': "Pits",
                                'time': rel_time_in,
                                'message': f"Driver {driver_number} enters pit in lap {lap_number}"
                            })

                            events.append({
                                'type': "Pits",
                                'time': rel_time_out,
                                'message': f"Driver {driver_number} exits pit in lap {lap_number}"
                            })
                            pit_count += 1
                        print(f"[INFO] Driver {driver_number}: Added {len(pit_data)} pit stop events")
                    else:
                        print(f"[INFO] Driver {driver_number}: No pit data found")
                else:
                    print(f"[ERROR] Failed fetching pit data for driver {driver_number}: {response.status_code}")
            except Exception as e:
                print(f"[ERROR] Exception while fetching pit data for driver {driver_number}: {str(e)}")

            time.sleep(0.2)

        print(f"[INFO] Added {pit_count * 2} pit events")
    except Exception as e:
        print(f"[ERROR] Failed fetching pit stop data: {e}")
        traceback.print_exc()

    try:
        print(f"[INFO] Fetching position changes data...")
        url = "https://api.openf1.org/v1/position_changes"
        params = {
            "session_key": session_key,
        }

        response = requests.get(url, params=params)

        if response.status_code == 200:
            position_changes = response.json()

            if position_changes and len(position_changes) > 0:
                print(f"[DEBUG] Sample position change: {json.dumps(position_changes[0], indent=2)}")

            print(f"[INFO] Processing {len(position_changes)} position changes...")
            overtake_count = 0
            for change in position_changes:
                
                rel_time = calculate_relative_time(change.get("date"), race_start_time)
                
                if change.get("position_change", 0) > 0:
                    events.append({
                        'type': "Overtake",
                        'time': rel_time,
                        'message': f"Driver {change.get('driver_number', 0)} overtakes to position {change.get('position', 0)}"
                    })
                    overtake_count += 1

            print(f"[INFO] Added {overtake_count} overtake events")
        else:
            print(f"[ERROR] Failed fetching position changes: {response.status_code}")
    except Exception as e:
        print(f"[ERROR] Failed fetching position changes: {e}")
        traceback.print_exc()
    
    try:
        print(f"[INFO] Fetching race control messages...")
        url = "https://api.openf1.org/v1/race_control_messages"
        params = {
            "session_key": session_key,
        }

        response = requests.get(url, params=params)

        if response.status_code == 200:
            rc_messages = response.json()

            if rc_messages and len(rc_messages) > 0:
                print(f"[DEBUG] Sample race control message: {json.dumps(rc_messages[0], indent=2)}")

            print(f"[INFO] Processing {len(rc_messages)} race control messages...")
            rc_count = 0
            for message in rc_messages:
                
                rel_time = calculate_relative_time(message.get("date"), race_start_time)

                category = message.get("category", "Race Control")
                msg_text = message.get("message", "")

                events.append({
                    'type': category,
                    'time': rel_time,
                    'message': msg_text
                })
                rc_count += 1

            print(f"[INFO] Added {rc_count} race control messages")
        else:
            print(f"[ERROR] Failed fetching race control messages: {response.status_code}")
    except Exception as e:
        print(f"[ERROR] Failed fetching race control messages: {e}")
        traceback.print_exc()

    try:
        print(f"[INFO] Fetching team radio messages...")
        url = "https://api.openf1.org/v1/team_radio"
        params = {
            "session_key": session_key,
        }

        radio_count = 0
        for driver_number in driver_numbers:
            local_params = params.copy()
            local_params["driver_number"] = driver_number

            try:
                response = requests.get(url, params=local_params)

                if response.status_code == 200:
                    radio_data = response.json()

                    if radio_data and len(radio_data) > 0:
                        
                        if driver_number == driver_numbers[0] and len(radio_data) > 0:
                            print(f"[DEBUG] Sample radio entry: {json.dumps(radio_data[0], indent=2)}")

                        for radio in radio_data:
                            
                            rel_time = calculate_relative_time(radio.get("date"), race_start_time)

                            events.append({
                                'type': "Radio",
                                'time': rel_time,
                                'message': f"Driver {driver_number}"
                            })
                            radio_count += 1
                        print(f"[INFO] Driver {driver_number}: Added {len(radio_data)} radio events")
                    else:
                        print(f"[INFO] Driver {driver_number}: No radio data found")
                else:
                    print(f"[ERROR] Failed fetching radio data for driver {driver_number}: {response.status_code}")
            except Exception as e:
                print(f"[ERROR] Exception while fetching radio data for driver {driver_number}: {str(e)}")
            
            time.sleep(0.2)

        print(f"[INFO] Added {radio_count} radio events")
    except Exception as e:
        print(f"[ERROR] Failed fetching team radio data: {e}")
        traceback.print_exc()
    
    custom_overtake_path = os.path.join(base_dir, "overtake_data.json")
    try:
        if os.path.exists(custom_overtake_path):
            print(f"[INFO] Processing custom overtake data from {custom_overtake_path}...")
            with open(custom_overtake_path, 'r') as f:
                overtake_data = json.load(f)

            custom_overtake_count = 0
            for overtake in overtake_data:
                events.append({
                    'type': "Overtake",
                    'time': overtake.get('time', 0),
                    'message': f"Driver {overtake.get('overtaker')} overtakes Driver {overtake.get('overtaken')}"
                })
                custom_overtake_count += 1

            print(f"[INFO] Added {custom_overtake_count} custom overtake events")
    except Exception as e:
        print(f"[ERROR] Exception while processing custom overtake data: {str(e)}")

    try:
        events.sort(key=lambda event: event.get('time', 0))
    except Exception as e:
        print(f"[ERROR] Exception while sorting events: {str(e)}")

    output_path = os.path.join(base_dir, "event_data.json")

    print(f"[INFO] Writing event data to file...")
    try:
        with open(output_path, 'w') as file:
            json.dump(events, file, separators=(',', ':'))  

        print(f"[SUCCESS] {output_path} file created successfully with {len(events)} total events")
    except Exception as e:
        print(f"[ERROR] Exception while writing {output_path}: {str(e)}")

    return events

if __name__ == "__main__":
    session_key = 9693
    make_event_data_file(session_key)