from pymongo import MongoClient
import json
import os
import traceback

connection_string = "mongodb+srv://Aryan:D4ThWEpRrHpSMpdx@cluster0.qfjzfgj.mongodb.net/bahrain?retryWrites=true&w=majority&appName=Cluster0"

client = MongoClient(connection_string)

def flatten_data(data, file_type, session_key):
    """
    Flatten nested data structures into a format suitable for MongoDB
    """
    flattened_data = []

    if file_type == "location_data":
        
        for driver in data:
            driver_id = driver.get('id')
            for pos in driver.get('positions', []):
                if len(pos) >= 4:
                    flattened_data.append({
                        "id": driver_id,
                        "x": pos[0],
                        "y": pos[1],
                        "z": pos[2] if len(pos) > 2 else 0,
                        "rel_time": pos[3],
                        "session_key": session_key
                    })

    elif file_type == "lap_data":
        
        for driver in data:
            driver_id = driver.get('id')
            for lap in driver.get('positions', []):
                if len(lap) >= 6:
                    flattened_data.append({
                        "id": driver_id,
                        "lap_number": lap[0],
                        "sector1_time": lap[1],
                        "sector2_time": lap[2],
                        "sector3_time": lap[3],
                        "lap_time": lap[4],
                        "rel_time": lap[5],
                        "session_key": session_key
                    })

    elif file_type == "car_data":
        
        driver_id = data.get('id')
        for pos in data.get('positions', []):
            if len(pos) >= 7:
                flattened_data.append({
                    "id": driver_id,
                    "rel_time": pos[0],
                    "rpm": pos[1],
                    "speed": pos[2],
                    "n_gear": pos[3],
                    "throttle": pos[4],
                    "drs": pos[5],
                    "brake": pos[6],
                    "session_key": session_key
                })

    elif file_type == "event_data":
        
        for event in data:
            event_data = {
                "type": event.get("type"),
                "time": event.get("time"),
                "message": event.get("message"),
                "session_key": session_key
            }
            flattened_data.append(event_data)

    elif file_type == "race_details":
        
        data["session_key"] = session_key
        flattened_data.append(data)

    elif file_type == "race_start_time":
        
        data["session_key"] = session_key
        flattened_data.append(data)

    return flattened_data


def upload_to_mongodb():
    """
    Scan F1_Data directory and upload all data files to MongoDB
    """
    base_dir = "F1_Data"

    
    if not os.path.exists(base_dir):
        print(f"Error: Base directory '{base_dir}' not found.")
        return False

    
    for session_dir in os.listdir(base_dir):
        session_path = os.path.join(base_dir, session_dir)

        
        if not os.path.isdir(session_path):
            continue

        print(f"Processing session {session_dir}...")
        session_key = session_dir  

        
        db_name = f"f1_{session_key}"
        db = client[db_name]
        print(f"Using database: {db_name}")

        
        json_files = [
            ("lap_data.json", "lap_data"),
            ("location_data.json", "location_data"),
            ("event_data.json", "events_data"),
            ("race_details.json", "race_details"),
            ("race_start_time.json", "race_start_time")
        ]

        for filename, collection_name in json_files:
            file_path = os.path.join(session_path, filename)

            if os.path.exists(file_path):
                print(f"Processing {filename}...")

                try:
                    with open(file_path, "r") as file:
                        data = json.load(file)

                    
                    collection = db[collection_name]
                    collection.delete_many({"session_key": session_key})
                    
                    flattened_data = flatten_data(data, collection_name, session_key)

                    if flattened_data:
                        
                        batch_size = 1000
                        for i in range(0, len(flattened_data), batch_size):
                            batch = flattened_data[i:i + batch_size]
                            if batch:
                                result = collection.insert_many(batch)
                                print(f"Inserted {len(result.inserted_ids)} records into {collection_name}")

                except Exception as e:
                    print(f"Error processing {file_path}: {str(e)}")
                    traceback.print_exc()

        
        car_data_dir = os.path.join(session_path, "car_data")
        if os.path.exists(car_data_dir) and os.path.isdir(car_data_dir):
            print(f"Processing car_data directory...")
            
            collection = db["car_data"]
            collection.delete_many({"session_key": session_key})

            
            for driver_file in os.listdir(car_data_dir):
                if driver_file.endswith('.json'):
                    driver_path = os.path.join(car_data_dir, driver_file)

                    try:
                        with open(driver_path, "r") as file:
                            driver_data = json.load(file)

                        
                        flattened_data = flatten_data(driver_data, "car_data", session_key)

                        if flattened_data:
                            
                            batch_size = 1000
                            for i in range(0, len(flattened_data), batch_size):
                                batch = flattened_data[i:i + batch_size]
                                if batch:
                                    result = collection.insert_many(batch)
                                    print(f"Inserted {len(result.inserted_ids)} records for driver {driver_file}")

                    except Exception as e:
                        print(f"Error processing {driver_path}: {str(e)}")
                        traceback.print_exc()

    print("Upload completed successfully!")
    return True

if __name__ == "__main__":
    print("Starting upload process to MongoDB...")
    upload_to_mongodb()