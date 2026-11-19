# 1. import requests
import requests
import json
import time
import psycopg
import config

# 2. url = the spending_by_award endpoint
url = "https://api.usaspending.gov/api/v2/search/spending_by_award/"


# 3. payload = the JSON from the browser test, as a Python dict
payload = {
"filters": {
    "place_of_performance_locations": [{"country": "USA", "state": "NV", "county": "003"}],
    "award_type_codes": ["A", "B", "C", "D"],
    "time_period": [{"start_date": "2024-10-01", "end_date": "2025-09-30"}]
},
"fields": ["Award ID", "Recipient Name", "Award Amount", "Awarding Agency", "Description"],
"sort": "Award Amount",
"order": "desc",
"limit": 100,
"page": 1
}

nv_list = [] 
current_page = 1 
has_next = True 

quarters = [
    {"start_date": "2024-10-01", "end_date": "2024-12-31"},
    {"start_date": "2025-01-01", "end_date": "2025-03-31"},
    {"start_date": "2025-04-01", "end_date": "2025-06-30"},
    {"start_date": "2025-07-01", "end_date": "2025-09-30"}
]

for quarter in quarters:
    payload["filters"]["time_period"] = [quarter]
    current_page = 1 
    has_next = True
    
    while has_next:
        payload["page"] = current_page 

        # 4. send a POST request with the payload
        response = requests.post(url, json=payload)

        # 5. print the status code
        print(response.status_code) 

        # 6. if it worked, turn the response into Python data with .json()
        data = response.json()
        # print(json.dumps(data, indent=4))

        # 7. print the results, then loop through them and print
        if response.status_code == 200:
            nv_list.extend(data["results"])
            has_next = data["page_metadata"]["hasNext"] 
            current_page += 1
        else:
            print(response.text)
            break 
        time.sleep(1)

print(len(nv_list))
# for award in nv_list:
#     print(f'Recipient Name: {award["Recipient Name"]}, Award Amount: {award["Award Amount"]:,}')

conn = psycopg.connect(
    dbname = config.DB_NAME,
    user = config.DB_USER,
    password = config.DB_PASSWORD,
    host = config.DB_HOST 
)

cur = conn.cursor()

contracts = [] 
for award in nv_list:
    contracts.append((award["generated_internal_id"], award["Award ID"], award["Recipient Name"], award["Award Amount"], award["Awarding Agency"], award["Description"]))

cur.executemany(
    """
    INSERT INTO contracts (generated_internal_id, award_id, recipient_name, award_amount, awarding_agency, description)
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (generated_internal_id) DO NOTHING 
    """,
    contracts
)

conn.commit() 
conn.close()