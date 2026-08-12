import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json
import os

def setup_missing():
    # 1. Load Discovery Report
    report_path = 'firestore_discovery_report.json'
    if not os.path.exists(report_path):
        print(f"Error: '{report_path}' not found. Run 'discover_firestore.py' first.")
        return

    with open(report_path, 'r', encoding='utf-8') as f:
        report = json.load(f)

    missing = report.get("missing_critical_collections", [])
    if not missing:
        print("No missing critical collections found. Your Firestore matches the production requirement.")
        return

    # 2. Initialize Firebase
    service_account_path = 'true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json'
    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"Connection Error: {e}")
        return

    db = firestore.client()

    # 3. Define templates for missing collections
    templates = {
        "Gym_Classes": {
            "class_id": "template_c1",
            "name": {"en": "Yoga Flow", "ar": "يوغا"},
            "coach_name": "Coach Marcus",
            "time": "10:00 AM",
            "max_capacity": 20,
            "type": "group"
        },
        "User_Diet_Plans": {
            "pers_ID": 0,
            "assigned_date": "2026-07-20",
            "meals": [{"time": "Breakfast", "items": "Oatmeal with fruits"}],
            "water_goal": 3.0,
            "coach_notes": "Follow strictly for 2 weeks."
        },
        "User_Progress_Stats": {
            "pers_ID": 0,
            "weight": 75.0,
            "body_fat_pct": 18.5,
            "recorded_at": "2026-07-20"
        },
        "User_Bookings": {
            "booking_id": "template_bk1",
            "pers_ID": 0,
            "class_id": "template_c1",
            "status": "confirmed",
            "timestamp": firestore.SERVER_TIMESTAMP
        },
        "Chat_Rooms": {
            "room_id": "template_chat1",
            "participants": [0, "coach_uid_1"],
            "last_message": "Welcome to TrueFit Chat!",
            "updated_at": firestore.SERVER_TIMESTAMP
        }
    }

    print(f"--- Setting up {len(missing)} Missing Collections ---")
    for col_name in missing:
        if col_name in templates:
            print(f"Creating Collection: {col_name}...")
            # Adding a template document
            db.collection(col_name).add(templates[col_name])
            print(f"  [OK] Initialized with production template.")
        else:
            print(f"  [!] No template defined for {col_name}. Skipping.")

    print("\nMissing collections have been initialized.")

if __name__ == "__main__":
    setup_missing()
