## Use this to generate service principal pat token

set APPLICATION_ID=”Client id"
set CLIENT_SECRET=your-client-secret
set TENANT_ID=”TENANT_ID"
set DATABRICKS_WORKSPACE_URL=databricks url

az login --service-principal --username %APPLICATION_ID% --password %CLIENT_SECRET% --tenant %TENANT_ID%

for /f "delims=" %i in ('az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d, --query accessToken --output tsv') do set ACCESS_TOKEN=%i
echo Access Token: %ACCESS_TOKEN%

curl -X POST %DATABRICKS_WORKSPACE_URL%/api/2.0/token/create ^
  -H "Authorization: Bearer %ACCESS_TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"lifetime_seconds\": 3600, \"comment\": \"Service Principal PAT\"}" -o pat_response.json

type pat_response.json

powershell -Command "Get-Content pat_response.json | ConvertFrom-Json | Select-Object -ExpandProperty token_value" > pat_token.txt
for /f "delims=" %i in (pat_token.txt) do set PAT_TOKEN=%i

echo Your PAT token is: %PAT_TOKEN%
