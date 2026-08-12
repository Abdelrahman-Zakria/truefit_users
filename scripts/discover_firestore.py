import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json
import os
from datetime import datetime

# Helper to handle Firestore types in JSON
def json_serial(obj):
    if hasattr(obj, 'isoformat'):
        return obj.isoformat()
    return str(obj)

def discover_firestore():
    # 1. Initialize Firebase
    service_account_path = 'true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json'
    if not os.path.exists(service_account_path):
        print(f"Error: '{service_account_path}' not found in the scripts directory.")
        return

    try:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"Connection Error: {e}")
        return

    db = firestore.client()

    discovery_results = {
        "existing_collections": {},
        "missing_critical_collections": []
    }

    # Define what we consider "critical" for production/coach integration
    critical_collections = [
        "promotions",
        "Gym_Subscription_types",
        "Gym_Classes",
        "User_Diet_Plans",
        "User_Progress_Stats",
        "User_Bookings",
        "Chat_Rooms"
    ]

    print("--- Discovering Firestore Structure ---")

    # Get all root-level collections
    collections = db.collections()

    existing_names = []
    for col in collections:
        existing_names.append(col.id)
        print(f"Found Collection: {col.id}")

        # Peek at the first document to understand field structure
        docs = list(col.limit(1).get())
        if docs:
            sample_data = docs[0].to_dict()
            # Convert non-serializable objects to string for JSON report
            serializable_sample = {k: json_serial(v) for k, v in sample_data.items()}
            discovery_results["existing_collections"][col.id] = {
                "fields": list(sample_data.keys()),
                "sample_values": serializable_sample
            }
        else:
            discovery_results["existing_collections"][col.id] = {"fields": [], "status": "empty"}

    # Identify missing critical collections
    for critical in critical_collections:
        if critical not in existing_names:
            discovery_results["missing_critical_collections"].append(critical)
            print(f"MISSING CRITICAL: {critical}")

    # Save results to a file for the next script to use
    with open('firestore_discovery_report.json', 'w', encoding='utf-8') as f:
        json.dump(discovery_results, f, indent=4, ensure_ascii=False, default=json_serial)

    print("\nDiscovery complete. Report saved to 'firestore_discovery_report.json'.")

if __name__ == "__main__":
    discover_firestore()
