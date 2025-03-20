import argparse
import time
import traceback
import os
import datetime

from make_location_data import make_location_data_file, get_driver_list
from make_lap_data import make_lap_data_file
from make_car_data import make_car_data_file
from make_event_data import make_event_data_file
from make_race_details import make_race_details_file
from race_utils import get_race_start_time, save_race_start_time, get_saved_race_start_time

def compile_race_data(session_key=9693, meeting_key=None, year=None, country_name=None):
    """
    Create all race data files in sequence and organize them in the F1_Data/[meeting_key] structure

    Args:
        session_key (int): F1 session key to use for data fetching
        meeting_key (int): Optional specific meeting key (will be fetched from API if not provided)
        year (int): Optional year to filter meetings (used if meeting_key not provided)
        country_name (str): Optional country name (used if meeting_key not provided)

    Returns:
        dict: Dictionary containing all the fetched data
    """
    print(f"[INFO] Compiling all F1 data files for session {session_key}...")
    start_time = time.time()

    if meeting_key is None:
        print("[INFO] No meeting key provided, fetching from API...")
        race_details = make_race_details_file(year=year, country_name=country_name)
        if race_details:
            meeting_key = race_details.get("meeting_key")
            print(f"[INFO] Using meeting_key: {meeting_key} for {race_details.get('race_name')}")
        else:
            print("[WARNING] Could not determine meeting_key. Using default directory structure.")
    else:
        race_details = make_race_details_file(meeting_key=meeting_key)

    race_start_time = get_saved_race_start_time(meeting_key)
    if not race_start_time:
        race_start_time = get_race_start_time(session_key)
        if race_start_time:
            save_race_start_time(race_start_time, meeting_key)
            print(f"[INFO] Race start time determined: {race_start_time}")
        else:
            print("[WARNING] Could not determine race start time automatically.")
    else:
        print(f"[INFO] Using previously saved race start time: {race_start_time}")

    result = {}

    try:
        print("\n" + "=" * 50)
        print("STEP 1: DRIVER POSITION DATA")
        print("=" * 50)
        location_data = make_location_data_file(session_key, meeting_key)
        result["location_data"] = location_data

        print("\n" + "=" * 50)
        print("STEP 2: LAP TIMING DATA")
        print("=" * 50)
        lap_data = make_lap_data_file(session_key, meeting_key)
        result["lap_data"] = lap_data

        print("\n" + "=" * 50)
        print("STEP 3: CAR TELEMETRY DATA")
        print("=" * 50)
        car_data = make_car_data_file(session_key, meeting_key)
        result["car_data"] = car_data

        print("\n" + "=" * 50)
        print("STEP 4: EVENT DATA")
        print("=" * 50)
        event_data = make_event_data_file(session_key, meeting_key)
        result["event_data"] = event_data

        end_time = time.time()
        print("\n" + "=" * 50)
        print(f"[SUCCESS] All data files created successfully in {end_time - start_time:.2f} seconds!")
        print("=" * 50)

        print("\nSummary:")
        print(f"  Meeting: {race_details.get('race_name') if race_details else 'Unknown'}")
        print(f"  Meeting Key: {meeting_key if meeting_key else 'Not specified'}")
        print(f"  Race Start Time: {race_start_time}")
        print(f"  Drivers: {len(location_data)}")
        print(f"  Events: {len(event_data)}")
        location_positions = sum(len(d.get('positions', [])) for d in location_data)
        print(f"  Total position data points: {location_positions}")

        if meeting_key:
            output_dir = os.path.join("F1_Data", str(meeting_key))
            print(f"\nAll data saved to: {os.path.abspath(output_dir)}")

    except Exception as e:
        print(f"[ERROR] Exception during data compilation: {str(e)}")
        traceback.print_exc()

    return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='F1 Race Data Compiler')
    parser.add_argument('--session', type=int, default=9472,
                        help='F1 session key (default: 9693 - Bahrain 2024)')
    parser.add_argument('--meeting', type=int, help='F1 meeting key')
    parser.add_argument('--year', type=int, help='Year of the race')
    parser.add_argument('--country', type=str, help='Country name for the race')
    parser.add_argument('--search', type=str, help='Search term to find a race')

    args = parser.parse_args()

    if args.search:
        # Search mode uses race_details module directly
        from make_race_details import search_race_by_name

        matches = search_race_by_name(args.search, args.year)
        if matches:
            try:
                choice = input("\nEnter number to select a race (or press Enter to exit): ")
                if choice and choice.isdigit() and 1 <= int(choice) <= len(matches):
                    selected = matches[int(choice) - 1]
                    meeting_key = selected.get("meeting_key")
                    compile_race_data(args.session, meeting_key=meeting_key)
            except Exception as e:
                print(f"Error during selection: {str(e)}")
    else:
        # Direct parameters mode
        compile_race_data(
            session_key=args.session,
            meeting_key=args.meeting,
            year=args.year,
            country_name=args.country
        )