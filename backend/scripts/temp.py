import pymongo
import json
import os
import requests
import xml.etree.ElementTree as ET
from tenacity import retry, wait_exponential, stop_after_attempt, RetryError
from concurrent.futures import ThreadPoolExecutor, as_completed

# Function to fetch stations from a route using RouteId


@retry(wait=wait_exponential(multiplier=1, min=2, max=10), stop=stop_after_attempt(10), reraise=True)
def fetch_stations_from_route(route_id):
    api_url = f"https://nmmtservice.infinium.management/TransistService.asmx/GetStationsFromRoute?RouteId={
        route_id}"
    print(f"Fetching stations for RouteId: {route_id}")
    try:
        response = requests.get(api_url, timeout=5)
        response.raise_for_status()  # Raise an exception for HTTP errors
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        raise e  # Re-raise exception to trigger retry

    if response.status_code == 200:
        try:
            print(f"Response status code: {response.status_code}")
            # Parse the XML response
            root = ET.fromstring(response.content)
            # Extract JSON data from the XML tags
            json_string = root.text
            return json.loads(json_string)
        except ET.ParseError as e:
            print(f"Failed to parse XML: {e}")
        except json.JSONDecodeError as e:
            print(f"Failed to decode JSON: {e}")
    else:
        print(f"Failed to fetch stations for RouteId: {
              route_id}. Status code: {response.status_code}")
        print(f"Response body: {response.text}")
    return None


# Connect to MongoDB with connection pooling
client = pymongo.MongoClient("mongodb://localhost:27017/", maxPoolSize=50)
db = client["NaviXplore"]
collection = db["NMMT-Buses"]

# Fetch documents from MongoDB where RouteId is present
documents = list(collection.find({"RouteId": {"$exists": True}}))

# Initialize a counter for updated documents
total_updated = 0

# Function to update MongoDB document


def update_mongodb_document(route_id, stations):
    query = {"RouteId": route_id}
    update = {"$set": {"stations": stations}}
    result = collection.update_one(query, update)
    if result.modified_count > 0:
        return 1
    else:
        return 0

# Function to process each document


def process_document(doc):
    route_id = doc['RouteId']
    try:
        stations = fetch_stations_from_route(route_id)
    except RetryError:
        print(f"Skipping RouteId: {route_id} after multiple retries")
        return 0

    if stations is not None and stations != 'NO DATA FOUND':
        return update_mongodb_document(route_id, stations)
    else:
        return update_mongodb_document(route_id, 'NO DATA FOUND')


# Use ThreadPoolExecutor for concurrent processing
with ThreadPoolExecutor(max_workers=10) as executor:
    futures = [executor.submit(process_document, doc) for doc in documents]
    for future in as_completed(futures):
        total_updated += future.result()

print(f"Documents updated successfully. Total documents updated: {
      total_updated}")
