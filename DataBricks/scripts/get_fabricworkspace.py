import requests
import json

access_token = None
headers = {
  'Authorization': f'Bearer {access_token}',
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}

url_get= f"https://api.fabric.microsoft.com/v1/workspaces/"
response_status = requests.get(url_get, headers=headers)
response_data = response_status.json()
status = (response_data.get('status'))
print(json.dumps(response_data["value"],indent=2))

for i in response_data["value"]:
    print(i.get('displayName'))