import os
import msal
from dotenv import load_dotenv

load_dotenv()

tenant_id = os.getenv('AZURE_TENANT_ID')
client_id = os.getenv('AZURE_CLIENT_ID')
client_secret = os.getenv('AZURE_CLIENT_SECRET')

# Azure AD Authority URL (for public cloud)
authority = f'https://login.microsoftonline.com/{tenant_id}'

# Scope for Microsoft Fabric (or any Azure API)
scope = ["https://api.fabric.microsoft.com/.default"]

print("Getting access token...")

# Use MSAL to acquire a token
app = msal.ConfidentialClientApplication(client_id, authority=authority, client_credential=client_secret)
# Get the token
token_response = app.acquire_token_for_client(scopes=scope)

if 'access_token' in token_response:
    access_token = token_response['access_token']
    print("Access token obtained successfully:", access_token)
else:
    print("Error obtaining access token:", token_response.get("error_description"))

