import requests
import json

url = "https://api.usaspending.gov/api/v2/search/spending_by_award_count/"

payload = {
    "filters": {
        "place_of_performance_locations": [{"country": "USA", "state": "NV", "county": "003"}],
        "award_type_codes": ["A", "B", "C", "D"],
        "time_period": [{"start_date": "2025-07-01", "end_date": "2025-09-30"}]
    }
}

response = requests.post(url, json=payload)
print(response.status_code)
print(json.dumps(response.json(), indent=4))