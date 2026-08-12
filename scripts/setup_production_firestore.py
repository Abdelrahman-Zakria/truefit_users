import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# NOTE: You will need to download your serviceAccountKey.json from Firebase Console
# and place it in this directory for this script to work locally.
# If running inside a CI/CD or specialized environment, use default credentials.

def setup_firestore():
    # 1. Initialize Firebase (Assumes local service account for script execution)
    try:
        cred = credentials.Certificate('true-fit-52715-firebase-adminsdk-fbsvc-e1f125a908.json')
        firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"Connection Error: {e}")
        print("Please ensure 'serviceAccountKey.json' is present in the scripts directory.")
        return

    db = firestore.client()

    # 2. Define the Schema for Production & Coach App Handshake
    schema = {
        # --- SHARED COLLECTIONS (Managed by Admin/Coach, Read by Users) ---
        "promotions": {
            "description": "Banners and news shown on Home screen",
            "sample": {
                "id": "b1",
                "title": {"en": "...", "ar": "..."},
                "imageUrl": "...",
                "targetRoute": "..."
            }
        },
        "Gym_Subscription_types": {
            "description": "Available membership plans",
            "sample": {
                "id": 1,
                "name": "Premium",
                "price": 2000,
                "features": ["..."]
            }
        },
        "Gym_Classes": {
            "description": "Scheduled group sessions managed by Coaches",
            "sample": {
                "class_id": "c1",
                "name": {"en": "Yoga", "ar": "يوغا"},
                "coach_name": "...",
                "time": "...",
                "max_capacity": 20
            }
        },

        # --- USER-SPECIFIC DATA (Written by Coaches/System, Read by Users) ---
        "User_Diet_Plans": {
            "description": "Personalized nutrition plans assigned by coaches",
            "sample": {
                "pers_ID": 8471,
                "assigned_date": "...",
                "meals": [{"time": "Breakfast", "items": "..."}],
                "coach_notes": "..."
            }
        },
        "User_Progress_Stats": {
            "description": "InBody results and workout metrics",
            "sample": {
                "pers_ID": 8471,
                "weight": 80.5,
                "body_fat_pct": 15.2,
                "recorded_at": "..."
            }
        },

        # --- TRANSACTIONAL DATA (Interaction between User & Coach) ---
        "User_Bookings": {
            "description": "User enrollments in classes or PT",
            "sample": {
                "booking_id": "bk_1",
                "pers_ID": 8471,
                "class_id": "c1",
                "status": "confirmed",
                "timestamp": "..."
            }
        },
        "Chat_Rooms": {
            "description": "Private messaging channels between users and coaches",
            "sample": {
                "room_id": "chat_8471_coach1",
                "participants": [8471, "coach_uid_1"],
                "last_message": "...",
                "updated_at": "..."
            }
        }
    }

    print("--- Firestore Schema Setup ---")
    for collection, info in schema.items():
        print(f"Verifying Collection: {collection}")
        # We don't necessarily 'create' collections in Firestore as they are implicit,
        # but we can seed a dummy document to ensure they exist and show up in the console.
        col_ref = db.collection(collection)
        docs = col_ref.limit(1).get()

        if not docs:
            print(f"  [!] Collection '{collection}' is missing. Creating with sample data...")
            col_ref.add(info['sample'])
        else:
            print(f"  [OK] Collection '{collection}' already contains data.")

    print("\nProduction Schema is now defined and verified.")

if __name__ == "__main__":
    setup_firestore()
