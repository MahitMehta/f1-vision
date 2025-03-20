import requests
import json
import os
import statistics
from datetime import datetime
import time

def get_meeting_details(meeting_key=None, year=None, country_name=None):
    """
    Fetches meeting details from the OpenF1 API

    Args:
        meeting_key (int): Optional specific meeting key to fetch
        year (int): Optional year to filter meetings
        country_name (str): Optional country name to filter meetings

    Returns:
        dict: Meeting details dictionary
    """
    url = "https://api.openf1.org/v1/meetings"
    params = {}

    if meeting_key:
        params["meeting_key"] = meeting_key
    if year:
        params["year"] = year
    if country_name:
        params["country_name"] = country_name

    print(f"[INFO] Fetching meeting details with params: {params}")

    try:
        response = requests.get(url, params=params)

        if response.status_code == 200:
            meetings = response.json()
            if meetings and len(meetings) > 0:
                
                selected_meeting = meetings[0]
                print(f"[SUCCESS] Found meeting: {selected_meeting.get('meeting_name', 'Unknown')}")
                return selected_meeting
            else:
                print(f"[ERROR] No meetings found matching the criteria")
                return None
        else:
            print(f"[ERROR] Failed to fetch meeting details: {response.status_code}")
            return None
    except Exception as e:
        print(f"[ERROR] Exception while fetching meeting details: {str(e)}")
        return None

def get_weather_data(meeting_key):
    """
    Fetches weather data for a specific meeting

    Args:
        meeting_key (int): Meeting key to fetch weather for

    Returns:
        dict: Dictionary with aggregated weather data
    """
    url = "https://api.openf1.org/v1/weather"
    params = {
        "meeting_key": meeting_key
    }

    print(f"[INFO] Fetching weather data for meeting {meeting_key}")

    try:
        response = requests.get(url, params=params)

        if response.status_code == 200:
            weather_data = response.json()
            if weather_data and len(weather_data) > 0:
                print(f"[SUCCESS] Found {len(weather_data)} weather data points")

                air_temps = [entry.get('air_temperature', 0) for entry in weather_data if entry.get('air_temperature')]
                track_temps = [entry.get('track_temperature', 0) for entry in weather_data if
                               entry.get('track_temperature')]
                rainfall = [entry.get('rainfall', 0) for entry in weather_data if entry.get('rainfall') is not None]
                humidity = [entry.get('humidity', 0) for entry in weather_data if entry.get('humidity')]

                weather_stats = {
                    "air_temperature": {
                        "avg": round(statistics.mean(air_temps), 1) if air_temps else None,
                        "min": round(min(air_temps), 1) if air_temps else None,
                        "max": round(max(air_temps), 1) if air_temps else None
                    },
                    "track_temperature": {
                        "avg": round(statistics.mean(track_temps), 1) if track_temps else None,
                        "min": round(min(track_temps), 1) if track_temps else None,
                        "max": round(max(track_temps), 1) if track_temps else None
                    },
                    "rainfall": {
                        "avg": round(statistics.mean(rainfall), 2) if rainfall else 0,
                        "max": round(max(rainfall), 2) if rainfall else 0,
                        "has_rain": any(r > 0 for r in rainfall) if rainfall else False
                    },
                    "humidity": {
                        "avg": round(statistics.mean(humidity), 1) if humidity else None
                    },
                    "sample_count": len(weather_data)
                }

                return weather_stats
            else:
                print(f"[WARNING] No weather data found for meeting {meeting_key}")
                return {
                    "air_temperature": {"avg": None, "min": None, "max": None},
                    "track_temperature": {"avg": None, "min": None, "max": None},
                    "rainfall": {"avg": 0, "max": 0, "has_rain": False},
                    "humidity": {"avg": None},
                    "sample_count": 0
                }
        else:
            print(f"[ERROR] Failed to fetch weather data: {response.status_code}")
            return None
    except Exception as e:
        print(f"[ERROR] Exception while fetching weather data: {str(e)}")
        return None

def make_race_details_file(meeting_key=None, year=None, country_name=None):
    """
    Creates a race_details.json file with information about the race/meeting

    Args:
        meeting_key (int): Optional specific meeting key
        year (int): Optional year to filter meetings
        country_name (str): Optional country name to filter meetings

    Returns:
        dict: Created race details dictionary
    """
    
    meeting = get_meeting_details(meeting_key, year, country_name)
    if not meeting:
        print("[ERROR] Failed to retrieve meeting details. Cannot create race details file.")
        return None

    meeting_key = meeting.get("meeting_key")

    weather = get_weather_data(meeting_key)

    race_details = {
        "meeting_key": meeting_key,
        "race_name": meeting.get("meeting_name"),
        "official_name": meeting.get("meeting_official_name"),
        "year": meeting.get("year"),
        "country": {
            "name": meeting.get("country_name"),
            "code": meeting.get("country_code"),
            "key": meeting.get("country_key")
        },
        "circuit": {
            "name": meeting.get("circuit_short_name"),
            "location": meeting.get("location"),
            "key": meeting.get("circuit_key")
        },
        "date_start": meeting.get("date_start"),
        "gmt_offset": meeting.get("gmt_offset"),
        "weather": weather
    }

    base_dir = "F1_Data"
    meeting_dir = os.path.join(base_dir, str(meeting_key))

    if not os.path.exists(base_dir):
        os.makedirs(base_dir)
        print(f"[INFO] Created base directory: {base_dir}")

    if not os.path.exists(meeting_dir):
        os.makedirs(meeting_dir)
        print(f"[INFO] Created meeting directory: {meeting_dir}")

    file_path = os.path.join(meeting_dir, "race_details.json")
    try:
        with open(file_path, 'w') as file:
            json.dump(race_details, file, indent=2)
        print(f"[SUCCESS] Created race details file: {file_path}")
    except Exception as e:
        print(f"[ERROR] Failed to write race details file: {str(e)}")
        return None

    return race_details

def search_race_by_name(search_term, year=None):
    """
    Search for a race by name

    Args:
        search_term (str): Part of race name to search for
        year (int): Optional year to filter by

    Returns:
        list: List of matching meetings
    """
    url = "https://api.openf1.org/v1/meetings"
    params = {}

    if year:
        params["year"] = year

    try:
        response = requests.get(url, params=params)

        if response.status_code == 200:
            all_meetings = response.json()
            
            matches = [
                meeting for meeting in all_meetings
                if search_term.lower() in meeting.get("meeting_name", "").lower() or
                   search_term.lower() in meeting.get("meeting_official_name", "").lower() or
                   search_term.lower() in meeting.get("country_name", "").lower() or
                   search_term.lower() in meeting.get("location", "").lower()
            ]

            for i, meeting in enumerate(matches):
                print(
                    f"{i + 1}. {meeting.get('meeting_name')} ({meeting.get('year')}) - {meeting.get('country_name')} [meeting_key: {meeting.get('meeting_key')}]")

            return matches
        else:
            print(f"[ERROR] Failed to search meetings: {response.status_code}")
            return []
    except Exception as e:
        print(f"[ERROR] Exception while searching meetings: {str(e)}")
        return []

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description='F1 Race Details Generator')
    parser.add_argument('--meeting', type=int, help='Meeting key (e.g., 1219 for Singapore 2023)')
    parser.add_argument('--year', type=int, help='Year (e.g., 2023)')
    parser.add_argument('--country', type=str, help='Country name (e.g., Singapore)')
    parser.add_argument('--search', type=str, help='Search for races by name')

    args = parser.parse_args()

    if args.search:
        
        matches = search_race_by_name(args.search, args.year)
        if matches:
            try:
                choice = input("\nEnter number to select a race (or press Enter to exit): ")
                if choice and choice.isdigit() and 1 <= int(choice) <= len(matches):
                    selected = matches[int(choice) - 1]
                    make_race_details_file(meeting_key=selected.get("meeting_key"))
            except Exception as e:
                print(f"Error during selection: {str(e)}")
    else:
        
        make_race_details_file(
            meeting_key=args.meeting,
            year=args.year,
            country_name=args.country
        )