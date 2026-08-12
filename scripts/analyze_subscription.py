import re
import os

def analyze_file(filepath):
    if not os.path.exists(filepath):
        return f"File not found: {filepath}"

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract model usage
    print(f"--- Analyzing {os.path.basename(filepath)} ---")

    # Search for field access in SubscriptionScreen
    if "subscription_screen.dart" in filepath:
        fields = re.findall(r'plan\.([a-zA-Z0-9_]+)', content)
        print(f"Fields accessed on 'plan' (MembershipPlanEntity): {set(fields)}")

        user_sub_fields = re.findall(r'state\.userSubscription\?\.([a-zA-Z0-9_]+)', content)
        print(f"Fields accessed on 'userSubscription': {set(user_sub_fields)}")

        # Check for conditional rendering
        if "if (state is SubscriptionPlansLoaded)" in content:
            print("UI depends on 'SubscriptionPlansLoaded' state.")

    # Search for model definition
    if "membership_plan_model.dart" in filepath:
        json_keys = re.findall(r"json\['([a-zA-Z0-9_]+)'\]", content)
        print(f"JSON keys mapped in MembershipPlanModel: {set(json_keys)}")

    print("-" * 30)

# Analyze relevant files
files_to_analyze = [
    r"C:/Users/tiger/StudioProjects/truefit_users/lib/features/subscription/presentation/screens/subscription_screen.dart",
    r"C:/Users/tiger/StudioProjects/truefit_users/lib/features/subscription/data/models/membership_plan_model.dart",
    r"C:/Users/tiger/StudioProjects/truefit_users/lib/features/subscription/presentation/cubit/subscription_cubit.dart"
]

for f in files_to_analyze:
    analyze_file(f)
